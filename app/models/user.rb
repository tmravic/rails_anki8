class User < ApplicationRecord
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
end
