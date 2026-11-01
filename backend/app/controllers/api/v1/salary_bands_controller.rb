class API::V1::SalaryBandsController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { salary_bands: @salary_bands.as_json }
  end

  def show
    render json: { salary_band: @salary_band.as_json }
  end

  def create
    if @salary_band.save
      render json: { salary_band: @salary_band.as_json }, status: :created
    else
      render_errors(@salary_band)
    end
  end

  def update
    if @salary_band.update(salary_band_params)
      render json: { salary_band: @salary_band.as_json }
    else
      render_errors(@salary_band)
    end
  end

  def destroy
    if @salary_band.destroy
      head :no_content
    else
      render_errors(@salary_band)
    end
  end

  private

    def salary_band_params
      params.require(:salary_band).permit(
        :country_id, :department_id, :job_title_id, :employment_level_id, :currency_id,
        :min_salary, :max_salary, :effective_from, :effective_to
      )
    end
end
