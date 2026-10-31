FactoryBot.define do
  factory :salary_band do
    country
    job_title
    department { job_title.department }
    employment_level
    currency
    min_salary { 80_000 }
    max_salary { 140_000 }
    effective_from { Date.current }

    after(:build) do |salary_band|
      next if salary_band.job_title.blank? || salary_band.employment_level.blank?

      JobTitleLevel.find_or_create_by!(
        job_title: salary_band.job_title,
        employment_level: salary_band.employment_level
      )
    end
  end
end
