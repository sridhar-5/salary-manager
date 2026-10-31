# == Schema Information
#
# Table name: employment_levels
#
#  id         :bigint           not null, primary key
#  name       :string(100)      not null
#  rank       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_employment_levels_on_name  (name) UNIQUE
#  index_employment_levels_on_rank  (rank) UNIQUE
#
class EmploymentLevel < ApplicationRecord
  has_many :job_title_levels, dependent: :destroy
  has_many :job_titles, through: :job_title_levels
  has_many :employees, dependent: :restrict_with_error
  has_many :salary_bands, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :rank, presence: true, uniqueness: true
  validates :rank, numericality: { only_integer: true }, allow_nil: true
end
