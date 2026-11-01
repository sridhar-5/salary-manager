class API::V1::EmploymentLevelsController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { employment_levels: @employment_levels.as_json }
  end

  def show
    render json: { employment_level: @employment_level.as_json }
  end

  def create
    if @employment_level.save
      render json: { employment_level: @employment_level.as_json }, status: :created
    else
      render_errors(@employment_level)
    end
  end

  def update
    if @employment_level.update(employment_level_params)
      render json: { employment_level: @employment_level.as_json }
    else
      render_errors(@employment_level)
    end
  end

  def destroy
    if @employment_level.destroy
      head :no_content
    else
      render_errors(@employment_level)
    end
  end

  private

    def employment_level_params
      params.require(:employment_level).permit(:name, :rank)
    end
end
