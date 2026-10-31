module API
  module EmployeeListParams
    FILTERS = [
      :with_country_id,
      :with_department_id,
      :with_job_title_id,
      :with_employment_level_id,
      :with_employment_status,
      :with_salary_min,
      :with_salary_max,
      :with_reporting_currency_id,
      :search_query
    ].freeze

    def employee_search_params(require_page: false)
      params.require(:page) if require_page
      params.permit(
        :page,
        :limit,
        :search,
        :sort,
        :order,
        filters: FILTERS,
        filterrific: FILTERS
      ).to_h.deep_symbolize_keys.tap do |search_params|
        search_params[:filters] ||= {}
        search_params[:filters].reverse_merge!(search_params.delete(:filterrific) || {})
        search_params[:search] ||= search_params[:filters].delete(:search_query)
      end
    end
  end
end
