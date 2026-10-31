FactoryBot.define do
  factory :compensation_record do
    employee
    currency { employee.country.currency }
    annual_salary { 120_000 }
    effective_from { Date.current }
    association :created_by, factory: :admin_user
  end
end
