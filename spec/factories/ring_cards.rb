FactoryBot.define do
  factory :ring_card do
    ring_number { generate(:ring_card_numbers) }
    association :user
  end
end
