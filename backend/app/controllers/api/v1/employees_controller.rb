class API::V1::EmployeesController < ApplicationController
  include API::EmployeeListParams

  load_and_authorize_resource except: :index

  def index
    authorize! :read, Employee

    query = API::Queries::EmployeesIndex.new(employee_search_params, ability: current_ability)
    query.call

    render json: {
      employees: query.records.map { |employee| serialize_employee(employee, query.usd_rates) },
      meta: {
        page: query.records.current_page,
        per_page: query.records.limit_value,
        total_count: query.count,
        total_pages: query.records.total_pages,
        reporting_currency: MoneyFormat.currency(Currency.usd)
      }
    }
  end

  def show
    @employee = Employee.preload(*API::Queries::EmployeesIndex::PRELOADS).find(@employee.id)
    render json: { employee: serialize_employee(@employee) }
  end

  def create
    if @employee.save
      render json: { employee: serialize_employee(@employee) }, status: :created
    else
      render_errors(@employee)
    end
  end

  def update
    if @employee.update(employee_params)
      render json: { employee: serialize_employee(@employee) }
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

    def serialize_employee(employee, usd_rates = ExchangeRate.rates_by_quote_currency)
      API::V1::EmployeesSerializer.new(employee, usd_rates:).serialize
    end

    def employee_params
      params.require(:employee).permit(
        :employee_number, :first_name, :last_name, :email,
        :country_id, :department_id, :job_title_id, :employment_level_id,
        :manager_id, :employment_status, :hire_date, :termination_date
      )
    end
end
