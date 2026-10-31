class API::V1::JobTitlesController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def job_title_params
    params.require(:job_title).permit(:title, :description, :department_id)
  end
end
