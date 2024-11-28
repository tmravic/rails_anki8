class EmployeeInfo < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_one :profile
end
