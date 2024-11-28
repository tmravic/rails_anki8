class Profile < ApplicationRecord
  belongs_to :employee_info

  delegate :user, to: :employee_info
end
