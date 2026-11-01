class API::V1::JobTitleLevelsController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { job_title_levels: @job_title_levels.as_json }
  end

  def show
    render json: { job_title_level: @job_title_level.as_json }
  end

  def create
    if @job_title_level.save
      render json: { job_title_level: @job_title_level.as_json }, status: :created
    else
      render_errors(@job_title_level)
    end
  end

  def update
    if @job_title_level.update(job_title_level_params)
      render json: { job_title_level: @job_title_level.as_json }
    else
      render_errors(@job_title_level)
    end
  end

  def destroy
    if @job_title_level.destroy
      head :no_content
    else
      render_errors(@job_title_level)
    end
  end

  private

    def job_title_level_params
      params.require(:job_title_level).permit(:job_title_id, :employment_level_id)
    end
end
