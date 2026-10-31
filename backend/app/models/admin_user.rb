# == Schema Information
#
# Table name: admin_users
#
#  id                 :bigint           not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           not null
#  encrypted_password :string           default(""), not null
#  failed_attempts    :integer          default(0), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  locked_at          :datetime
#  sign_in_count      :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_admin_users_on_email  (email) UNIQUE
#
class AdminUser < ApplicationRecord
  devise :database_authenticatable, :validatable, :trackable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :admin_user_roles, dependent: :destroy
  has_many :roles, through: :admin_user_roles
  has_many :compensation_records, foreign_key: :created_by_id, inverse_of: :created_by, dependent: :restrict_with_error

  def has_role?(name)
    role_names.include?(name.to_s)
  end

  def role_names
    @role_names ||= roles.pluck(:name)
  end

  def as_api_json
    {
      id: id,
      email: email,
      roles: roles.order(:name).pluck(:name)
    }
  end
end
