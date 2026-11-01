class API::V1::ExchangeRatesController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { exchange_rates: @exchange_rates.as_json }
  end

  def show
    render json: { exchange_rate: @exchange_rate.as_json }
  end

  def create
    if @exchange_rate.save
      render json: { exchange_rate: @exchange_rate.as_json }, status: :created
    else
      render_errors(@exchange_rate)
    end
  end

  def update
    if @exchange_rate.update(exchange_rate_params)
      render json: { exchange_rate: @exchange_rate.as_json }
    else
      render_errors(@exchange_rate)
    end
  end

  def destroy
    if @exchange_rate.destroy
      head :no_content
    else
      render_errors(@exchange_rate)
    end
  end

  private

    def exchange_rate_params
      params.require(:exchange_rate).permit(:base_currency_id, :quote_currency_id, :rate, :effective_date)
    end
end
