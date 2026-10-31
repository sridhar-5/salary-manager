class API::V1::CountriesController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def country_params
    params.require(:country).permit(:name, :iso_code, :currency_id)
  end
end
