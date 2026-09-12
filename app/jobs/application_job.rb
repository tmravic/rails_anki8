class ApplicationJob < ActiveJob::Base
  # Active Job rescue_from handlers — Solid Queue never sees these exceptions
  # unless they bubble out of perform_now (retry attempts exhausted, or unhandled).
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3

  # Raised when a GlobalID argument (e.g. User) was deleted before the worker ran.
  discard_on ActiveJob::DeserializationError

  after_discard do |job, error|
    Rails.logger.info("[ApplicationJob] discarded #{job.class} id=#{job.job_id} error=#{error.class}: #{error.message}")
  end
end

