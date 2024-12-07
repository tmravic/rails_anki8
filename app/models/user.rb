class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, [:user, :moderator, :admin]

  after_initialize :set_default_role, :if => :new_record?
  before_save -> { puts "Before saving #{self}" }

  def set_default_role
    self.role ||= :user
  end
end
