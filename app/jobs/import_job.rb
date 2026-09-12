class ImportJob < ApplicationJob
  class TransientError < StandardError; end
  class PermanentError < StandardError; end

  queue_as :default

  # Re-enqueues via ActiveJob#retry_job → SolidQueue adapter#enqueue_at
  # (a new solid_queue_jobs row + solid_queue_scheduled_executions).
  retry_on TransientError, wait: 2.seconds, attempts: 3

  # Swallows the error. The current Solid Queue job is marked finished;
  # nothing is written to solid_queue_failed_executions.
  discard_on PermanentError

  # mode: "ok" | "retry" | "discard" | "fail"
  # record: optional Active Record (used to demo DeserializationError)
  def perform(mode = "ok", record = nil)
    case mode.to_s
    when "retry"
      raise TransientError, "upstream timeout"
    when "discard"
      raise PermanentError, "record gone"
    when "fail"
      raise RuntimeError, "unhandled boom"
    else
      Rails.logger.info("========== Import Job mode=#{mode.inspect} record=#{record.inspect} ==========")
    end
  end
end

