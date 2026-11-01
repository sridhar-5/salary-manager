class API::V1::EmployeesController < ApplicationController
  include API::EmployeeListParams

  load_and_authorize_resource except: :index

  def index
    authorize! :read, Employee

    query = API::Queries::EmployeesIndex.new(employee_search_params, ability: current_ability)
    query.call
    employees = query.records

    render json: {
      employees: employees.map { |employee| API::V1::EmployeesSerializer.new(employee).serialize },
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

  def show
    render json: { employee: API::V1::EmployeesSerializer.new(@employee).serialize }
  end

  def create
    if @employee.save
      render json: { employee: API::V1::EmployeesSerializer.new(@employee).serialize }, status: :created
    else
      render_errors(@employee)
    end
  end

  def update
    if @employee.update(employee_params)
      render json: { employee: API::V1::EmployeesSerializer.new(@employee).serialize }
    else
      render_errors(@employee)
    end
  end

  def destroy
    if @employee.destroy
      head :no_content
    else
      render_errors(@employee)
    end
  end

  private

    def employee_params
      params.require(:employee).permit(
        :employee_number, :first_name, :last_name, :email,
        :country_id, :department_id, :job_title_id, :employment_level_id,
        :manager_id, :employment_status, :hire_date, :termination_date
      )
    end
end
