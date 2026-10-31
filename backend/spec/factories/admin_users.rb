FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :super_admin do
      after(:create) do |admin_user|
        admin_user.roles << Role.find_or_create_by!(name: "super_admin")
      end
    end

    trait :compensation_admin do
      after(:create) do |admin_user|
        admin_user.roles << Role.find_or_create_by!(name: "compensation_admin")
      end
    end

    trait :viewer do
      after(:create) do |admin_user|
        admin_user.roles << Role.find_or_create_by!(name: "viewer")
      end
    end
  end
end
