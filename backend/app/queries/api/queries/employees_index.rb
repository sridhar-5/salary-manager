module API
  module Queries
    class EmployeesIndex < Base
      ASSOCIATIONS = %i[country department job_title employment_level].freeze

      def initialize(params, ability:)
        @ability = ability
        super(params)
      end

      def self.find_record(employee, ability:, params:)
        currency = reporting_currency_for(params)
        record = Employee.accessible_by(ability).where(id: employee.id)
          .with_reporting_pay(currency: currency, on: Date.current)
          .first || employee
        ActiveRecord::Associations::Preloader.new(
          records: [ record ],
          associations: ASSOCIATIONS + %i[manager]
        ).call
        record
      end

      def self.reporting_currency_for(params)
        filters = (params[:filters] || {}).to_h.symbolize_keys
        if (identifier = Employee.integer_identifier(filters[:with_reporting_currency_id]))
          found = Currency.find_by(id: identifier)
          return found if found
        end

        Currency.find_by(code: "USD") || Currency.order(:id).first
      end

      def reporting_currency
        @reporting_currency ||= self.class.reporting_currency_for(params)
      end

      def unconverted_count
        attribute_scope.where("reporting_amount IS NULL").count
      end

      def summary_filters
        {
          q: search.presence,
          country_id: Employee.integer_identifier(filter_params[:with_country_id]),
          department_id: Employee.integer_identifier(filter_params[:with_department_id]),
          job_title_id: Employee.integer_identifier(filter_params[:with_job_title_id]),
          employment_level_id: Employee.integer_identifier(filter_params[:with_employment_level_id]),
          employment_status: summary_status,
          salary_min: summary_decimal(:with_salary_min),
          salary_max: summary_decimal(:with_salary_max),
          reporting_currency_id: reporting_currency&.id
        }
      end

      private

      attr_reader :ability

      def default_scope
        Employee.accessible_by(ability)
          .with_reporting_pay(currency: reporting_currency, on: Date.current)
          .preload(*ASSOCIATIONS)
      end

      def search_records
        return scope unless search.present?

        @scope = scope.search_query(search)
      end

      def filter_records
        @scope = Filters.filter(filter_params: filter_params, scope: scope, names: Filters::ATTRIBUTE_NAMES)
        @attribute_scope = scope
        @scope = Filters.filter(filter_params: filter_params, scope: scope, names: Filters::SALARY_NAMES)
      end

      def sort_records
        @scope = scope.order(last_name: :asc, first_name: :asc, id: :asc)
      end

      def filter_params
        (filters || {}).to_h.symbolize_keys
      end

      def attribute_scope
        @attribute_scope || scope
      end

      def summary_status
        status = filter_params[:with_employment_status].to_s
        Employee::EMPLOYMENT_STATUSES.include?(status) ? status : nil
      end

      def summary_decimal(key)
        Employee.decimal_amount(filter_params[key])&.to_s("F")
      end

      class Filters
        ATTRIBUTE_NAMES = %i[
          with_country_id
          with_department_id
          with_job_title_id
          with_employment_level_id
          with_employment_status
        ].freeze
        SALARY_NAMES = %i[
          with_salary_min
          with_salary_max
        ].freeze
        NAMES = (ATTRIBUTE_NAMES + SALARY_NAMES).freeze

        class << self
          def filter(filter_params:, scope:, names: NAMES)
            names.each do |filter_name|
              scope = new(
                filter: filter_name,
                value: filter_params[filter_name],
                scope: scope
              ).filter
            end
            scope
          end
        end

        def initialize(filter:, value:, scope:)
          @filter = filter
          @value = value
          @scope = scope
        end

        def filter
          return @scope unless @value.present?

          @scope.public_send(@filter, @value)
        end
      end
    end
  end
end
