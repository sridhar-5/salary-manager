class API::V1::EmployeesController < API::V1::ResourcesController
  include API::EmployeeListParams

  load_and_authorize_resource except: :index

  def index
    authorize! :read, Employee

    query = API::Queries::EmployeesIndex.new(employee_search_params, ability: current_ability)
    query.call
    employees = query.records

    render json: {
      employees: employees.map { |employee| employee_json(employee, query.reporting_currency) },
      meta: {
        page: employees.current_page,
        per_page: employees.limit_value,
        total_count: employees.total_count,
        total_pages: employees.total_pages,
        reporting_currency: MoneyFormat.currency(query.reporting_currency),
        unconverted_count: query.unconverted_count
      }
    }
  end

  private

  def serialize(item)
    search_params = employee_search_params
    record = API::Queries::EmployeesIndex.find_record(item, ability: current_ability, params: search_params)
    employee_json(
      record,
      API::Queries::EmployeesIndex.reporting_currency_for(search_params),
      include_manager: true
    )
  end

  def employee_json(employee, reporting_currency, include_manager: false)
    API::V1::EmployeesSerializer.new(employee, reporting_currency:, include_manager:).serialize
  end

  def employee_params
    params.require(:employee).permit(
      :employee_number, :first_name, :last_name, :email,
      :country_id, :department_id, :job_title_id, :employment_level_id,
      :manager_id, :employment_status, :hire_date, :termination_date
    )
  end
end
