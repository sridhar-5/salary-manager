# == Schema Information
#
# Table name: job_titles
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string(150)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_job_titles_on_title  (title) UNIQUE
#
class JobTitle < ApplicationRecord
  has_many :job_title_levels, dependent: :destroy
  has_many :employment_levels, through: :job_title_levels
  has_many :employees, dependent: :restrict_with_error

  validates :title, presence: true, uniqueness: true, length: { maximum: 150 }
end
