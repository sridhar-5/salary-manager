FactoryBot.define do
  factory :currency do
    sequence(:code) do |n|
      chars = ("A".."Z").to_a
      "#{chars[(n / 676) % 26]}#{chars[(n / 26) % 26]}#{chars[n % 26]}"
    end
    sequence(:name) { |n| "Currency #{n}" }

    trait :dollar do
      code { "USD" }
      name { "US Dollar" }
    end
  end
end
