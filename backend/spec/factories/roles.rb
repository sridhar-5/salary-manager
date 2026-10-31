FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Assigned access" }
  end
end
