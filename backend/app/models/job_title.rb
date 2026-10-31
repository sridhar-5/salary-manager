# == Schema Information
#
# Table name: job_titles
#
#  id            :bigint           not null, primary key
#  description   :text
#  title         :string(150)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :bigint           not null
#
# Indexes
#
#  index_job_titles_on_department_id            (department_id)
#  index_job_titles_on_department_id_and_title  (department_id,title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#
class JobTitle < ApplicationRecord
  belongs_to :department

  has_many :job_title_levels, dependent: :destroy
  has_many :employment_levels, through: :job_title_levels
  has_many :employees, dependent: :restrict_with_error
  has_many :salary_bands, dependent: :restrict_with_error

  validates :title, presence: true, uniqueness: { scope: :department_id }, length: { maximum: 150 }
end
