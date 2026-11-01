class API::V1::CountriesController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { countries: @countries.as_json }
  end

  def show
    render json: { country: @country.as_json }
  end

  def create
    if @country.save
      render json: { country: @country.as_json }, status: :created
    else
      render_errors(@country)
    end
  end

  def update
    if @country.update(country_params)
      render json: { country: @country.as_json }
    else
      render_errors(@country)
    end
  end

  def destroy
    if @country.destroy
      head :no_content
    else
      render_errors(@country)
    end
  end

  private

    def country_params
      params.require(:country).permit(:name, :iso_code, :currency_id)
    end
end
