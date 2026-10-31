FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    description { "Handles department work" }
  end
end
