module API
  module Queries
    class EmployeesIndex < Base
      PRELOADS = [
        :country,
        :department,
        :job_title,
        :employment_level,
        :manager,
        { payslips: :currency },
        { compensation_records: :currency }
      ].freeze

      def initialize(params, ability:)
        @ability = ability
        super(params)
      end

      def usd_rates
        @usd_rates ||= ExchangeRate.rates_by_quote_currency
      end

      private

      def default_scope
        Employee.accessible_by(@ability)
      end

      def sort_records
        @scope = scope.order(last_name: :asc, first_name: :asc, id: :asc)
      end

      def filter_records
        apply_search_filter
        apply_country_filter
        apply_department_filter
        apply_job_title_filter
        apply_level_filter
        apply_status_filter
        apply_min_salary_filter
      end

      def paginate_records
        @scope = scope.preload(*PRELOADS).page(page).per(limit)
      end

      def apply_search_filter
        return if params[:search].blank?

        @scope = scope.search(params[:search])
      end

      def apply_country_filter
        return if filters[:with_country_id].blank?

        @scope = scope.in_country(filters[:with_country_id])
      end

      def apply_department_filter
        return if filters[:with_department_id].blank?

        @scope = scope.in_department(filters[:with_department_id])
      end

      def apply_job_title_filter
        return if filters[:with_job_title_id].blank?

        @scope = scope.with_job_title(filters[:with_job_title_id])
      end

      def apply_level_filter
        return if filters[:with_employment_level_id].blank?

        @scope = scope.at_level(filters[:with_employment_level_id])
      end

      def apply_status_filter
        return if filters[:with_employment_status].blank?

        @scope = scope.with_status(filters[:with_employment_status])
      end

      def apply_min_salary_filter
        return if filters[:min_salary].blank?

        @scope = scope.joins(:compensation_records).where(compensation_records: { annual_salary: filters[:min_salary].., effective_to: nil, currency_id: Currency.usd.id })
      end
    end
  end
end
