# Live demo: how ApplicationJob retry_on / discard_on land in Solid Queue tables.
#   bin/rails runner scripts/demo_retry_discard.rb
#
# retry_on / discard_on are Active Job APIs (rescue_from). Solid Queue only
# stores the outcome: scheduled retry, finished (discarded), or failed.

module DemoRetryDiscard
  module_function

  def run
    process = register_worker
    puts "ActiveJob adapter: #{ActiveJob::Base.queue_adapter_name}"
    puts "Worker process id: #{process.id}"

    section("1. retry_on TransientError — job is finished, a NEW scheduled job is inserted")
    demo_retry(process)

    section("2. retry_on exhausted — exception bubbles, Solid Queue records a failed_execution")
    demo_retry_exhausted(process)

    section("3. discard_on PermanentError — current job finished, no failed_execution, no retry")
    demo_discard(process)

    section("4. unhandled RuntimeError — ClaimedExecution#failed_with → solid_queue_failed_executions")
    demo_fail(process)

    section("5. ApplicationJob discard_on DeserializationError — GlobalID target gone")
    demo_deserialization(process)

    section("6. Solid Queue's own Job#retry — NOT retry_on; re-dispatches a failed row")
    demo_solid_queue_retry(process)
  ensure
    process&.deregister
  end

  def demo_retry(process)
    job = ImportJob.perform_later("retry")
    original = SolidQueue::Job.find(job.provider_job_id)
    show_job("enqueued", original)

    perform_ready!(original, process)
    original.reload
    show_job("after worker (exception handled by retry_on)", original)

    retry_row = sibling(original)
    show_job("retry_job inserted this scheduled row", retry_row)
    puts "same ActiveJob id: #{original.active_job_id == retry_row.active_job_id}"
    puts "original finished? #{original.finished?}  retry status=#{retry_row.status}  scheduled_at=#{retry_row.scheduled_at}"
    retry_row.discard
  end

  def demo_retry_exhausted(process)
    job = ImportJob.perform_later("retry")
    current = SolidQueue::Job.find(job.provider_job_id)
    last_failed = nil

    3.times do |i|
      perform_ready!(current, process)
      current.reload
      puts "attempt #{i + 1}: solid_queue_jobs.id=#{current.id} status=#{current.status} finished=#{current.finished?} failed=#{current.failed?}"

      if current.failed?
        last_failed = current
        break
      end

      nxt = sibling(current)
      make_due!(nxt)
      current = nxt
    end

    show_job("after 3rd attempt (attempts: 3 includes the original)", last_failed)
    puts "failed error: #{last_failed&.failed_execution&.error&.slice('exception_class', 'message')}"
  end

  def demo_discard(process)
    before_failed = SolidQueue::FailedExecution.count
    before_jobs = SolidQueue::Job.count

    job = ImportJob.perform_later("discard")
    sq = SolidQueue::Job.find(job.provider_job_id)
    perform_ready!(sq, process)
    sq.reload
    show_job("discarded job", sq)

    puts "new solid_queue_jobs rows: #{SolidQueue::Job.count - before_jobs} (1 original, 0 retries)"
    puts "new failed_executions: #{SolidQueue::FailedExecution.count - before_failed}"
    puts "finished? #{sq.finished?}  failed? #{sq.failed?}"
  end

  def demo_fail(process)
    job = ImportJob.perform_later("fail")
    sq = SolidQueue::Job.find(job.provider_job_id)
    error = perform_ready!(sq, process)
    sq.reload
    show_job("unhandled error", sq)
    puts "worker re-raised: #{error.class}: #{error&.message}"
    puts "failed_execution.error: #{sq.failed_execution&.error&.slice('exception_class', 'message')}"
  end

  def demo_deserialization(process)
    user = User.create!(
      email_address: "demo-retry-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      name: "Demo Discard"
    )
    job = ImportJob.perform_later("ok", user)
    user.destroy!

    sq = SolidQueue::Job.find(job.provider_job_id)
    perform_ready!(sq, process)
    sq.reload
    show_job("DeserializationError discarded by ApplicationJob", sq)
    puts "finished? #{sq.finished?}  failed? #{sq.failed?}  (discard_on swallows, so no failed_execution)"
  end

  def demo_solid_queue_retry(process)
    job = ImportJob.perform_later("fail")
    sq = SolidQueue::Job.find(job.provider_job_id)
    perform_ready!(sq, process)
    sq.reload
    puts "before Job#retry: status=#{sq.status} executions=#{sq.arguments['executions']}"

    sq.retry
    sq.reload
    show_job("after SolidQueue::Job#retry (same row, counters reset, back to ready)", sq)
    puts "failed_execution gone? #{sq.failed_execution.nil?}  ready? #{sq.ready?}  executions=#{sq.arguments['executions']}"
    sq.discard
  end

  def register_worker
    SolidQueue::Process.register(
      kind: "Worker",
      pid: Process.pid,
      hostname: Socket.gethostname,
      name: "demo-retry-discard-#{SecureRandom.hex(4)}",
      metadata: { queues: "default" }
    )
  end

  def perform_ready!(sq_job, process)
    sq_job.reload
    raise "expected ready job, got #{sq_job.status.inspect}" unless sq_job.ready?

    error = nil
    SolidQueue::ClaimedExecution.claiming([sq_job.id], process.id) do |claimed|
      SolidQueue::ReadyExecution.where(job_id: sq_job.id).delete_all
      begin
        claimed.first.perform
      rescue Exception => e
        error = e
      end
    end
    error
  end

  def make_due!(sq_job)
    now = Time.current
    sq_job.update!(scheduled_at: now)
    execution = sq_job.scheduled_execution
    raise "expected scheduled job #{sq_job.id}, got #{sq_job.status.inspect}" unless execution

    execution.update!(scheduled_at: now)
    SolidQueue::ScheduledExecution.dispatch_jobs([sq_job.id])
    sq_job.reload
  end

  def sibling(sq_job)
    SolidQueue::Job.where(active_job_id: sq_job.active_job_id).where.not(id: sq_job.id).order(:id).last
  end

  def show_job(label, sq_job)
    puts "-- #{label} --"
    return puts("(nil)") if sq_job.nil?

    args = sq_job.arguments
    puts({
      solid_queue_job_id: sq_job.id,
      active_job_id: sq_job.active_job_id,
      class_name: sq_job.class_name,
      status: sq_job.status,
      finished_at: sq_job.finished_at,
      scheduled_at: sq_job.scheduled_at,
      executions: args["executions"],
      exception_executions: args["exception_executions"],
      arguments: args["arguments"]
    }.inspect)
  end

  def section(title)
    puts "\n" + "=" * 72
    puts title
    puts "=" * 72
  end
end

DemoRetryDiscard.run
