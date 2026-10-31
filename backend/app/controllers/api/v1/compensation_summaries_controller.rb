class API::V1::CompensationSummariesController < ApplicationController
  include API::EmployeeListParams

  def show
    authorize! :read, CompensationRecord
    query = API::Queries::EmployeesIndex.new(employee_search_params, ability: current_ability)
    query.call
    render json: CompensationSummary.new(query).call
  end
end
