FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:iso_code) do |n|
      chars = ("A".."Z").to_a
      "#{chars[(n / 26) % 26]}#{chars[n % 26]}"
    end
    association :currency
  end
end
