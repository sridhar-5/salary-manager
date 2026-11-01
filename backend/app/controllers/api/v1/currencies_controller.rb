class API::V1::CurrenciesController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { currencies: @currencies.as_json }
  end

  def show
    render json: { currency: @currency.as_json }
  end

  def create
    if @currency.save
      render json: { currency: @currency.as_json }, status: :created
    else
      render_errors(@currency)
    end
  end

  def update
    if @currency.update(currency_params)
      render json: { currency: @currency.as_json }
    else
      render_errors(@currency)
    end
  end

  def destroy
    if @currency.destroy
      head :no_content
    else
      render_errors(@currency)
    end
  end

  private

    def currency_params
      params.require(:currency).permit(:code, :name)
    end
end
