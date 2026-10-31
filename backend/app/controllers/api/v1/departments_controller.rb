class API::V1::DepartmentsController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def department_params
    params.require(:department).permit(:name, :description)
  end
end
