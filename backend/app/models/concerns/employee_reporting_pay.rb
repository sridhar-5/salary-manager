module EmployeeReportingPay
  extend ActiveSupport::Concern

  included do
    scope :with_reporting_pay, ->(currency:, on: Date.current) {
      inner = joins(reporting_pay_join(currency, on)).select(reporting_pay_columns(currency))
      unscope(:joins, :select).from(inner, :employees)
    }

    scope :reporting_salary_between, ->(minimum, maximum) {
      relation = all
      relation = relation.where("reporting_amount >= ?", minimum) if minimum
      relation = relation.where("reporting_amount <= ?", maximum) if maximum
      relation
    }
  end

  class_methods do
    def reporting_pay_join(currency, on)
      pay = CompensationRecord.latest_per_employee(on).to_sql
      currency_id = currency&.id
      fx = sanitize_sql_array([ <<~SQL.squish, { reporting_currency_id: currency_id, as_of: on } ])
        LEFT JOIN LATERAL (
          SELECT CASE
            WHEN er.base_currency_id = current_pay.currency_id AND er.quote_currency_id = :reporting_currency_id THEN er.rate
            WHEN er.base_currency_id = :reporting_currency_id AND er.quote_currency_id = current_pay.currency_id THEN (1::numeric / er.rate)
          END AS multiplier
          FROM exchange_rates er
          WHERE current_pay.id IS NOT NULL
            AND :reporting_currency_id IS NOT NULL
            AND current_pay.currency_id <> :reporting_currency_id
            AND er.effective_date <= :as_of
            AND (
              (er.base_currency_id = current_pay.currency_id AND er.quote_currency_id = :reporting_currency_id)
              OR (er.base_currency_id = :reporting_currency_id AND er.quote_currency_id = current_pay.currency_id)
            )
          ORDER BY er.effective_date DESC, er.id DESC
          LIMIT 1
        ) fx ON TRUE
      SQL

      "LEFT JOIN (#{pay}) current_pay ON current_pay.employee_id = employees.id #{fx}"
    end

    def reporting_pay_columns(currency)
      amount = sanitize_sql_array([ <<~SQL.squish, { reporting_currency_id: currency&.id } ])
        CASE
          WHEN current_pay.id IS NULL THEN NULL
          WHEN current_pay.currency_id = :reporting_currency_id THEN current_pay.annual_salary
          ELSE ROUND(current_pay.annual_salary * fx.multiplier, 4)
        END AS reporting_amount
      SQL

      [
        "employees.*",
        "current_pay.id AS compensation_id",
        "current_pay.annual_salary AS annual_salary",
        "current_pay.currency_id AS compensation_currency_id",
        "current_pay.currency_code AS currency_code",
        "current_pay.effective_from AS compensation_effective_from",
        "current_pay.effective_to AS compensation_effective_to",
        amount
      ]
    end
  end
end
