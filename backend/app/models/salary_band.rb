# == Schema Information
#
# Table name: salary_bands(Defines acceptable compensation ranges for comparable employee groups.)
#
#  id                  :bigint           not null, primary key
#  effective_from      :date             not null
#  effective_to        :date
#  max_salary          :decimal(19, 4)   not null
#  min_salary          :decimal(19, 4)   not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  country_id          :bigint           not null
#  currency_id         :bigint           not null
#  department_id       :bigint           not null
#  employment_level_id :bigint           not null
#  job_title_id        :bigint           not null
#
# Indexes
#
#  index_salary_bands_on_country_id           (country_id)
#  index_salary_bands_on_currency_id          (currency_id)
#  index_salary_bands_on_department_id        (department_id)
#  index_salary_bands_on_employment_level_id  (employment_level_id)
#  index_salary_bands_on_job_title_id         (job_title_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (employment_level_id => employment_levels.id)
#  fk_rails_...  (job_title_id => job_titles.id)
#
class SalaryBand < ApplicationRecord
  belongs_to :country
  belongs_to :department
  belongs_to :job_title
  belongs_to :employment_level
  belongs_to :currency

  validates :min_salary, presence: true, numericality: { greater_than: 0 }
  validates :max_salary, presence: true, numericality: { greater_than: 0 }
  validates :effective_from, presence: true

  validate :max_salary_not_below_min_salary
  validate :effective_to_not_before_effective_from
  validate :employment_level_must_apply_to_job_title
  validate :job_title_must_belong_to_department

  private

  def max_salary_not_below_min_salary
    return if min_salary.blank? || max_salary.blank?
    return if max_salary >= min_salary

    errors.add(:max_salary, "must be greater than or equal to the minimum salary")
  end

  def effective_to_not_before_effective_from
    return if effective_to.blank? || effective_from.blank?
    return if effective_to >= effective_from

    errors.add(:effective_to, "must be on or after the effective from date")
  end

  def employment_level_must_apply_to_job_title
    return if job_title_id.blank? || employment_level_id.blank?
    return if JobTitleLevel.exists?(job_title_id:, employment_level_id:)

    errors.add(:employment_level, "is not applicable to the selected job title")
  end

  def job_title_must_belong_to_department
    return if job_title_id.blank? || department_id.blank?
    return if job_title.department_id == department_id

    errors.add(:job_title, "must belong to the selected department")
  end
end
