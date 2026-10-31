class API::V1::ExchangeRatesController < API::V1::ResourcesController
  load_and_authorize_resource

  private

  def exchange_rate_params
    params.require(:exchange_rate).permit(:base_currency_id, :quote_currency_id, :rate, :effective_date)
  end
end
