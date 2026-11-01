class API::V1::DepartmentsController < ApplicationController
  load_and_authorize_resource

  def index
    render json: { departments: @departments.as_json }
  end

  def show
    render json: { department: @department.as_json }
  end

  def create
    if @department.save
      render json: { department: @department.as_json }, status: :created
    else
      render_errors(@department)
    end
  end

  def update
    if @department.update(department_params)
      render json: { department: @department.as_json }
    else
      render_errors(@department)
    end
  end

  def destroy
    if @department.destroy
      head :no_content
    else
      render_errors(@department)
    end
  end

  private

    def department_params
      params.require(:department).permit(:name, :description)
    end
end
