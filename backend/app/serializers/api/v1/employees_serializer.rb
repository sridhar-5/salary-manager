module API
  module V1
    class EmployeesSerializer
      def initialize(employee, reporting_currency:, include_manager: false)
        @employee = employee
        @reporting_currency = reporting_currency
        @include_manager = include_manager
      end

      def serialize
        payload = {
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
          reporting_currency: MoneyFormat.currency(reporting_currency),
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
          current_compensation: compensation_json
        }
        payload[:manager] = manager_json if include_manager
        payload
      end

      private

      attr_reader :employee, :reporting_currency, :include_manager

      def compensation_json
        compensation_id = attribute("compensation_id")
        return nil if compensation_id.blank?

        {
          id: compensation_id.to_i,
          annual_salary: MoneyFormat.format_money(attribute("annual_salary")),
          currency: {
            id: attribute("compensation_currency_id").to_i,
            code: attribute("currency_code")
          },
          effective_from: attribute("compensation_effective_from"),
          effective_to: attribute("compensation_effective_to"),
          reporting_amount: MoneyFormat.format_money(attribute("reporting_amount"))
        }
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

      def attribute(name)
        employee.read_attribute(name)
      end
    end
  end
end
