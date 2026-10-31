# == Schema Information
#
# Table name: admin_user_roles
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#  role_id       :bigint           not null
#
# Indexes
#
#  index_admin_user_roles_on_admin_user_id              (admin_user_id)
#  index_admin_user_roles_on_admin_user_id_and_role_id  (admin_user_id,role_id) UNIQUE
#  index_admin_user_roles_on_role_id                    (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#  fk_rails_...  (role_id => roles.id)
#
class AdminUserRole < ApplicationRecord
  belongs_to :admin_user
  belongs_to :role

  validates :role_id, uniqueness: { scope: :admin_user_id }
end
