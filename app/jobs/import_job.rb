class ImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "========== Import Job =========="
  end
end
