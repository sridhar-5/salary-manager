FactoryBot.define do
  factory :job_title do
    department
    sequence(:title) { |n| "Job Title #{n}" }
    description { "Describes the role" }
  end
end
