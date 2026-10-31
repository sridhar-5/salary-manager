class API::V1::JobTitleLevelsController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def job_title_level_params
    params.require(:job_title_level).permit(:job_title_id, :employment_level_id)
  end
end
