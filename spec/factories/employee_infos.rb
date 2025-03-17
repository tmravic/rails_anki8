FactoryBot.define do
  factory :employee_info do
    department { ["Engineering", "Marketing", "Sales", "HR", "Finance"].sample }
    association :user
    association :company
  end
end