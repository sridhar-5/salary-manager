module API
  module V1
    class EmployeesSerializer
      def initialize(employee)
        @employee = employee
      end

      def serialize
        {
          id: employee.id,
          employee_number: employee.employee_number,
          first_name: employee.first_name,
          last_name: employee.last_name,
          email: employee.email,
          employment_status: employee.employment_status,
          hire_date: employee.hire_date,
          termination_date: employee.termination_date,
          country_id: employee.country_id,
          department_id: employee.department_id,
          job_title_id: employee.job_title_id,
          employment_level_id: employee.employment_level_id,
          manager_id: employee.manager_id,
          created_at: employee.created_at,
          updated_at: employee.updated_at,
          reporting_currency: reporting_currency_payload,
          country: {
            id: employee.country_id,
            name: employee.country.name,
            iso_code: employee.country.iso_code
          },
          department: { id: employee.department_id, name: employee.department.name },
          job_title: { id: employee.job_title_id, title: employee.job_title.title },
          employment_level: {
            id: employee.employment_level_id,
            name: employee.employment_level.name,
            rank: employee.employment_level.rank
          },
          current_compensation: compensation_json,
          manager: manager_json
        }
      end

      private

      attr_reader :employee

      def compensation_json
        record = current_compensation_record
        return nil if record.blank?

        {
          id: record.id,
          annual_salary: MoneyFormat.format_money(record.annual_salary),
          currency: {
            id: record.currency_id,
            code: record.currency.code
          },
          effective_from: record.effective_from,
          effective_to: record.effective_to,
          reporting_amount: MoneyFormat.format_money(converted_amount(record))
        }
      end

      def current_compensation_record
        employee.compensation_records
          .covering(Date.current)
          .includes(:currency)
          .order(effective_from: :desc, id: :desc)
          .first
      end

      def converted_amount(record)
        currency = default_reporting_currency
        return nil if currency.blank?
        return record.annual_salary if record.currency_id == currency.id

        rate = exchange_multiplier(record.currency_id, currency.id)
        return nil if rate.nil?

        (record.annual_salary * rate).round(4)
      end

      def exchange_multiplier(from_id, to_id)
        direct = ExchangeRate.where(base_currency_id: from_id, quote_currency_id: to_id)
          .where(effective_date: ..Date.current)
          .order(effective_date: :desc, id: :desc)
          .pick(:rate)
        return direct if direct

        inverse = ExchangeRate.where(base_currency_id: to_id, quote_currency_id: from_id)
          .where(effective_date: ..Date.current)
          .order(effective_date: :desc, id: :desc)
          .pick(:rate)
        return nil if inverse.nil? || inverse.zero?

        1 / inverse
      end

      def reporting_currency_payload
        record = current_compensation_record
        {
          id: record.currency_id,
          code: record.currency&.code,
          name: record.currency&.name
        } if record

        MoneyFormat.currency(default_reporting_currency)
      end

      def default_reporting_currency
        @default_reporting_currency ||= Currency.find_by(code: "USD") || Currency.order(:id).first
      end

      def manager_json
        manager = employee.manager
        return nil if manager.blank?

        {
          id: manager.id,
          first_name: manager.first_name,
          last_name: manager.last_name,
          employee_number: manager.employee_number
        }
      end
    end
  end
end
