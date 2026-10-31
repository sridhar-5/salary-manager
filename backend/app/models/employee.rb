# == Schema Information
#
# Table name: employees
#
#  id                  :bigint           not null, primary key
#  email               :string(255)      not null
#  employee_number     :string(50)       not null
#  employment_status   :enum             not null, enum_type: employment_status
#  first_name          :string(100)      not null
#  hire_date           :date             not null
#  last_name           :string(100)      not null
#  termination_date    :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  country_id          :bigint           not null
#  department_id       :bigint           not null
#  employment_level_id :bigint           not null
#  job_title_id        :bigint           not null
#  manager_id          :bigint
#
# Indexes
#
#  index_employees_on_country_id_and_department_id    (country_id,department_id)
#  index_employees_on_department_id_and_job_title_id  (department_id,job_title_id)
#  index_employees_on_email                           (email) UNIQUE
#  index_employees_on_employee_number                 (employee_number) UNIQUE
#  index_employees_on_employment_level_id             (employment_level_id)
#  index_employees_on_employment_status               (employment_status)
#  index_employees_on_manager_id                      (manager_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (employment_level_id => employment_levels.id)
#  fk_rails_...  (job_title_id => job_titles.id)
#  fk_rails_...  (manager_id => employees.id)
#
# Enums
#
#  employment_status  active, terminated
#
class Employee < ApplicationRecord
  belongs_to :country
  belongs_to :department
  belongs_to :job_title
  belongs_to :employment_level
  belongs_to :manager, class_name: "Employee", optional: true

  has_many :direct_reports, class_name: "Employee", foreign_key: :manager_id, inverse_of: :manager, dependent: :nullify

  enum :employment_status, { active: "active", terminated: "terminated" }, validate: true

  validates :employee_number, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hire_date, presence: true
  validates :termination_date, presence: true, if: :terminated?
  validates :termination_date, absence: true, unless: :terminated?

  validate :employment_level_must_apply_to_job_title
  validate :termination_date_not_before_hire_date
  validate :manager_cannot_be_self

  private

  def employment_level_must_apply_to_job_title
    return if job_title_id.blank? || employment_level_id.blank?
    return if JobTitleLevel.exists?(job_title_id:, employment_level_id:)

    errors.add(:employment_level, "is not applicable to the selected job title")
  end

  def termination_date_not_before_hire_date
    return if termination_date.blank? || hire_date.blank?
    return if termination_date >= hire_date

    errors.add(:termination_date, "must be on or after the hire date")
  end

  def manager_cannot_be_self
    return if manager_id.blank? || id.blank?
    return if manager_id != id

    errors.add(:manager, "cannot be the employee")
  end
end
