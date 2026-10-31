# == Schema Information
#
# Table name: departments
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string(100)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_departments_on_name  (name) UNIQUE
#
class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
