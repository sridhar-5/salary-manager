class API::V1::CompensationRecordsController < API::V1::ResourcesController
  before_action :set_employee
  load_and_authorize_resource through: :employee

  def create
    record.created_by = current_admin_user
    record.currency ||= record.employee.country.currency
    super
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def compensation_record_params
    params.require(:compensation_record).permit(:annual_salary, :currency_id, :effective_from, :effective_to)
  end
end
