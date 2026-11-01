FactoryBot.define do
  factory :payslip do
    employee
    currency { employee.country.currency }
    sequence(:payslip_number) { |n| "PS#{n.to_s.rjust(8, "0")}" }
    period_start { Date.current.beginning_of_month }
    period_end { Date.current.end_of_month }
    pay_date { Date.current.end_of_month }
    gross_pay { 10_000 }
    deductions { 2_000 }
    net_pay { 8_000 }
    status { :paid }
  end
end
