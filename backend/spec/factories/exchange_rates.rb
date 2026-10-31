FactoryBot.define do
  factory :exchange_rate do
    association :base_currency, factory: :currency
    association :quote_currency, factory: :currency
    rate { 83.25 }
    sequence(:effective_date) { |n| Date.current - n.days }
  end
end
