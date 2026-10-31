# == Schema Information
#
# Table name: job_title_levels
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employment_level_id :bigint           not null
#  job_title_id        :bigint           not null
#
# Indexes
#
#  index_job_title_levels_on_employment_level_id                   (employment_level_id)
#  index_job_title_levels_on_job_title_id_and_employment_level_id  (job_title_id,employment_level_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (employment_level_id => employment_levels.id)
#  fk_rails_...  (job_title_id => job_titles.id)
#
class JobTitleLevel < ApplicationRecord
  belongs_to :job_title
  belongs_to :employment_level

  validates :employment_level_id, uniqueness: { scope: :job_title_id }
end
