class API::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_admin_user!, only: :create
  skip_authorization_check only: :create

  def create
    admin_user = AdminUser.find_for_database_authentication(email: session_params[:email])

    if admin_user&.valid_for_authentication? { admin_user.valid_password?(session_params[:password]) }
      admin_user.reset_failed_attempts!
      admin_user.update_tracked_fields!(request)
      token, _payload = Warden::JWTAuth::UserEncoder.new.call(admin_user, :admin_user, nil)
      render json: { token: token, admin_user: admin_user.as_api_json }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def show
    authorize! :read, current_admin_user
    render json: { admin_user: current_admin_user.as_api_json }
  end

  def destroy
    authorize! :read, current_admin_user
    token = request.authorization.to_s.split.last
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    JwtDenylist.revoke_jwt(payload, current_admin_user)
    head :no_content
  end

  private

  def session_params
    params.permit(:email, :password)
  end
end
