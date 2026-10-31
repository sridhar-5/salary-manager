class API::V1::EmployeesController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def employee_params
    params.require(:employee).permit(
      :employee_number, :first_name, :last_name, :email,
      :country_id, :department_id, :job_title_id, :employment_level_id,
      :manager_id, :employment_status, :hire_date, :termination_date
    )
  end
end
