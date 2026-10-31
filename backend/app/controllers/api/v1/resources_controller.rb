class API::V1::ResourcesController < ApplicationController
  def index
    render json: { collection_key => collection.map { |item| serialize(item) } }
  end

  def show
    render json: { resource_key => serialize(record) }
  end

  def create
    if record.save
      render json: { resource_key => serialize(record) }, status: :created
    else
      render_errors(record)
    end
  end

  def update
    if record.update(resource_params)
      render json: { resource_key => serialize(record) }
    else
      render_errors(record)
    end
  end

  def destroy
    if record.destroy
      head :no_content
    else
      render_errors(record)
    end
  end

  private

  def collection
    instance_variable_get(:"@#{controller_name}")
  end

  def record
    instance_variable_get(:"@#{controller_name.singularize}")
  end

  def collection_key
    controller_name
  end

  def resource_key
    controller_name.singularize
  end

  def resource_params
    send(:"#{controller_name.singularize}_params")
  end

  def serialize(item)
    item.as_json
  end

  def render_errors(model)
    render json: { errors: model.errors.as_json }, status: :unprocessable_entity
  end
end
