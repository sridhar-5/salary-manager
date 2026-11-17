module API
  module V1
    class EmployeesSerializer
      def initialize(employee, usd_rates:)
        @employee = employee
        @usd_rates = usd_rates
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
          reporting_currency: MoneyFormat.currency(Currency.usd),
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
          payslips: payslips_json,
          manager: manager_json
        }
      end

      private

      attr_reader :employee, :usd_rates

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
          usd_rate: usd_rate_for(record)
        }
      end

      def usd_rate_for(record)
        return format_rate(1) if record.currency_id == Currency.usd.id

        format_rate(usd_rates[record.currency_id])
      end

      def format_rate(rate)
        return nil if rate.nil?

        format("%.10f", BigDecimal(rate.to_s))
      end

      def payslips_json
        ordered_payslips.map { |payslip| PayslipsSerializer.new(payslip).serialize }
      end

      def ordered_payslips
        if employee.payslips.loaded?
          employee.payslips.sort_by { |payslip| [ payslip.pay_date, payslip.id ] }.reverse
        else
          employee.payslips.includes(:currency).newest_first
        end
      end

      def current_compensation_record
        records = if employee.compensation_records.loaded?
          employee.compensation_records.select { |record| covers_today?(record) }
        else
          employee.compensation_records.covering(Date.current).includes(:currency)
        end
        records.max_by { |record| [ record.effective_from, record.id ] }
      end

      def covers_today?(record)
        record.effective_from <= Date.current && (record.effective_to.nil? || record.effective_to >= Date.current)
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
