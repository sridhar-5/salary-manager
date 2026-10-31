class API::V1::CurrenciesController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def currency_params
    params.require(:currency).permit(:code, :name)
  end
end
