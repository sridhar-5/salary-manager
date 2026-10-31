# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#
class Role < ApplicationRecord
  has_many :admin_user_roles, dependent: :restrict_with_error
  has_many :admin_users, through: :admin_user_roles

  validates :name, presence: true, uniqueness: true
end
