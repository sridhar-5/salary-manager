class API::V1::JobTitlesController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { job_titles: @job_titles.as_json }
  end

  def show
    render json: { job_title: @job_title.as_json }
  end

  def create
    if @job_title.save
      render json: { job_title: @job_title.as_json }, status: :created
    else
      render_errors(@job_title)
    end
  end

  def update
    if @job_title.update(job_title_params)
      render json: { job_title: @job_title.as_json }
    else
      render_errors(@job_title)
    end
  end

  def destroy
    if @job_title.destroy
      head :no_content
    else
      render_errors(@job_title)
    end
  end

  private

    def job_title_params
      params.require(:job_title).permit(:title, :description, :department_id)
    end
end
