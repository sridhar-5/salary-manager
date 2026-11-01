module API
  module Queries
    class EmployeesIndex
      DEFAULT_LIMIT = 10
      DEFAULT_PAGE = 1
      PRELOADS = %i[country department job_title employment_level manager].freeze

      attr_reader :records, :unconverted_count

      def initialize(params, ability:)
        @params = params
        @ability = ability
        @page = params[:page].present? ? params[:page].to_i : DEFAULT_PAGE
        @limit = params[:limit].present? ? params[:limit].to_i : DEFAULT_LIMIT
        @search = params[:search].to_s.strip
        @filters = (params[:filters] || {}).to_h.symbolize_keys
      end

      def call
        relation = Employee.accessible_by(@ability)
        relation = apply_search(relation)
        relation = apply_attribute_filters(relation)
        relation = with_reporting_pay(relation)
        @unconverted_count = relation.where("reporting_amount IS NULL").count
        relation = apply_salary_filters(relation)
        @records = relation.order(last_name: :asc, first_name: :asc, id: :asc).preload(*PRELOADS).page(@page).per(@limit)
        self
      end

      def reporting_currency
        @reporting_currency ||= self.class.reporting_currency_for(@params)
      end

      def self.reporting_currency_for(params)
        filters = (params[:filters] || {}).to_h.symbolize_keys
        if (identifier = integer_identifier(filters[:with_reporting_currency_id]))
          found = Currency.find_by(id: identifier)
          return found if found
        end

        Currency.find_by(code: "USD") || Currency.order(:id).first
      end

      def self.integer_identifier(value)
        return nil if value.blank?

        Integer(value, 10)
      rescue ArgumentError, TypeError
        nil
      end

      private

      def apply_search(relation)
        return relation if @search.blank?

        like = "%#{Employee.sanitize_sql_like(@search)}%"
        relation.where(
          <<~SQL.squish,
            employees.first_name ILIKE :term
            OR employees.last_name ILIKE :term
            OR employees.employee_number ILIKE :term
            OR (employees.first_name || ' ' || employees.last_name) ILIKE :term
          SQL
          term: like
        )
      end

      def apply_attribute_filters(relation)
        relation = filter_id(relation, :country_id, @filters[:with_country_id])
        relation = filter_id(relation, :department_id, @filters[:with_department_id])
        relation = filter_id(relation, :job_title_id, @filters[:with_job_title_id])
        relation = filter_id(relation, :employment_level_id, @filters[:with_employment_level_id])
        filter_status(relation)
      end

      def filter_id(relation, column, value)
        identifier = self.class.integer_identifier(value)
        return relation if identifier.nil?

        relation.where(column => identifier)
      end

      def filter_status(relation)
        status = @filters[:with_employment_status].to_s
        return relation unless Employee::EMPLOYMENT_STATUSES.include?(status)

        relation.where(employment_status: status)
      end

      def apply_salary_filters(relation)
        minimum = decimal_amount(@filters[:with_salary_min])
        maximum = decimal_amount(@filters[:with_salary_max])
        relation = relation.where("reporting_amount >= ?", minimum) if minimum
        relation = relation.where("reporting_amount <= ?", maximum) if maximum
        relation
      end

      def decimal_amount(value)
        return nil if value.blank?

        decimal = BigDecimal(value.to_s)
        decimal.finite? ? decimal : nil
      rescue ArgumentError
        nil
      end

      def with_reporting_pay(relation, on: Date.current)
        currency = reporting_currency
        inner = relation.joins(reporting_pay_join(currency, on)).select(reporting_pay_columns(currency))
        relation.unscope(:joins, :select).from(inner, :employees)
      end

      def reporting_pay_join(currency, on)
        pay = CompensationRecord.latest_per_employee(on).to_sql
        fx = sanitize_sql([ <<~SQL.squish, { reporting_currency_id: currency&.id, as_of: on } ])
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
        amount = sanitize_sql([ <<~SQL.squish, { reporting_currency_id: currency&.id } ])
          CASE
            WHEN current_pay.id IS NULL THEN NULL
            WHEN current_pay.currency_id = :reporting_currency_id THEN current_pay.annual_salary
            ELSE ROUND(current_pay.annual_salary * fx.multiplier, 4)
          END AS reporting_amount
        SQL
        reporting_currency_columns = sanitize_sql([
          "?::bigint AS reporting_currency_id, ?::varchar AS reporting_currency_code, ?::varchar AS reporting_currency_name",
          currency&.id,
          currency&.code,
          currency&.name
        ])

        [
          "employees.*",
          "current_pay.id AS compensation_id",
          "current_pay.annual_salary AS annual_salary",
          "current_pay.currency_id AS compensation_currency_id",
          "current_pay.currency_code AS currency_code",
          "current_pay.effective_from AS compensation_effective_from",
          "current_pay.effective_to AS compensation_effective_to",
          amount,
          reporting_currency_columns
        ]
      end

      def sanitize_sql(array)
        Employee.send(:sanitize_sql_array, array)
      end
    end
  end
end
