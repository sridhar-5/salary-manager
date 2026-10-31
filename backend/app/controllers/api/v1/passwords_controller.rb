class API::V1::PasswordsController < ApplicationController
  def update
    authorize! :update, current_admin_user

    if current_admin_user.update_with_password(password_params)
      render json: { admin_user: current_admin_user.as_api_json }
    else
      render json: { errors: current_admin_user.errors.as_json }, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.permit(:current_password, :password, :password_confirmation).to_h
  end
end
