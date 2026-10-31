FactoryBot.define do
  factory :employment_level do
    sequence(:name) { |n| "Level #{n}" }
    sequence(:rank)
  end
end
