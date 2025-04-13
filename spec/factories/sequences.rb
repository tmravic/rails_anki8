FactoryBot.define do
  sequence(:user_factory_email) { |n| "user#{n}@example.com" }
  sequence(:ring_card_numbers) { |n| "#{n}" }
end
