class User < ApplicationRecord
  # Intentionally retained objects — never cleared, simulating a memory leak.
  LEAKED_OBJECTS = []

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :cards
  has_many :posts
  has_one :ring_card
  has_one :employee_info
  has_one :profile, through: :employee_info

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, [ :user, :moderator, :admin ]

  after_initialize :set_default_role, if: :new_record?
  before_save -> { puts "Before saving #{self}" }

  def set_default_role
    self.role ||= :user
  end

  # Appends large strings to a class-level array that is never garbage-collected.
  def self.leak_memory!(iterations: 500, payload_size: 50_000)
    iterations.times do |i|
      LEAKED_OBJECTS << ("leak-payload-" * (payload_size / 13)) + i.to_s
    end
  end

  def self.profile_memory_leak!
    require "memory_profiler"

    GC.start

    report = MemoryProfiler.report do
      10.times { leak_memory!(iterations: 100, payload_size: 50_000) }
    end

    report.pretty_print(detailed_report: false, scale_bytes: true)

    puts "Leak store: #{LEAKED_OBJECTS.size} objects, #{(LEAKED_OBJECTS.sum(&:bytesize) / 1_024.0 / 1_024.0).round(2)} MB"
  end
end
