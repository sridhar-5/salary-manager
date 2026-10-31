class ApplicationController < ActionController::API
  before_action :authenticate_admin_user!
  before_action :set_paper_trail_whodunnit

  check_authorization

  rescue_from CanCan::AccessDenied do
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: exception.message }, status: :bad_request
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def set_paper_trail_whodunnit
    admin_user = warden.user(:admin_user)
    return if admin_user.blank?

    PaperTrail.request.whodunnit = admin_user.id.to_s
  end
end
