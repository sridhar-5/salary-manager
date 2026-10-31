class API::V1::EmploymentLevelsController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def employment_level_params
    params.require(:employment_level).permit(:name, :rank)
  end
end
