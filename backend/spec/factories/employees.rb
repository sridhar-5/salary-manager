FactoryBot.define do
  factory :employee do
    sequence(:employee_number) { |n| "EMP#{n.to_s.rjust(4, "0")}" }
    first_name { "Ada" }
    sequence(:last_name) { |n| "Lovelace#{n}" }
    sequence(:email) { |n| "employee#{n}@example.com" }
    country
    department
    job_title
    employment_level
    employment_status { :active }
    hire_date { Date.current }

    after(:build) do |employee|
      next if employee.job_title.blank? || employee.employment_level.blank?

      JobTitleLevel.find_or_create_by!(
        job_title: employee.job_title,
        employment_level: employee.employment_level
      )
    end

    trait :terminated do
      employment_status { :terminated }
      termination_date { Date.current }
    end
  end
end
