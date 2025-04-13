FactoryBot.define do
  factory :user do
    name { "John Doe" }
    add_attribute(:password) { "password123" }
    email_address { generate(:user_factory_email) }

    traits_for_enum :role
    # Automatically generate traits for the role enum
    # enum role: [:user, :moderator, :admin]


    trait :with_ring_card do
      transient do
        ring_number { generate(:ring_card_numbers) }
      end

      after(:build) do |user, evaluator|
        user.ring_card = build(
          :ring_card, ring_number: evaluator.ring_number
        )
      end
    end

    factory :user_with_employee_info do
      callback(:after_create) do |user|
        create(:employee_info, user: user)
      end
    end
  end
end
