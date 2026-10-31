class API::V1::SalaryBandsController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def salary_band_params
    params.require(:salary_band).permit(
      :country_id, :department_id, :job_title_id, :employment_level_id, :currency_id,
      :min_salary, :max_salary, :effective_from, :effective_to
    )
  end
end
