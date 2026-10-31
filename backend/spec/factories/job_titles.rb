FactoryBot.define do
  factory :job_title do
    sequence(:title) { |n| "Job Title #{n}" }
    description { "Describes the role" }
  end
end
