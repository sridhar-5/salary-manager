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
  has_many :compensation_records, dependent: :restrict_with_error

  enum :employment_status, { active: "active", terminated: "terminated" }, validate: true

  include EmployeeReportingPay
  extend Filterrific::ActiveRecordExtension

  EMPLOYMENT_STATUSES = %w[active terminated].freeze

  filterrific(
    available_filters: %i[
      search_query
      with_country_id
      with_department_id
      with_job_title_id
      with_employment_level_id
      with_employment_status
      with_salary_min
      with_salary_max
    ]
  )

  def self.search_query(term)
    sanitized = term.to_s.strip
    return all if sanitized.blank?

    like = "%#{sanitize_sql_like(sanitized)}%"
    where(
      <<~SQL.squish,
        employees.first_name ILIKE :term
        OR employees.last_name ILIKE :term
        OR employees.employee_number ILIKE :term
        OR (employees.first_name || ' ' || employees.last_name) ILIKE :term
      SQL
      term: like
    )
  end

  def self.with_country_id(country_id)
    identifier = integer_identifier(country_id)
    return all if identifier.nil?

    where(country_id: identifier)
  end

  def self.with_department_id(department_id)
    identifier = integer_identifier(department_id)
    return all if identifier.nil?

    where(department_id: identifier)
  end

  def self.with_job_title_id(job_title_id)
    identifier = integer_identifier(job_title_id)
    return all if identifier.nil?

    where(job_title_id: identifier)
  end

  def self.with_employment_level_id(employment_level_id)
    identifier = integer_identifier(employment_level_id)
    return all if identifier.nil?

    where(employment_level_id: identifier)
  end

  def self.with_employment_status(status)
    value = status.to_s
    return all unless EMPLOYMENT_STATUSES.include?(value)

    where(employment_status: value)
  end

  def self.with_salary_min(amount)
    decimal = decimal_amount(amount)
    return all if decimal.nil?

    where("reporting_amount >= ?", decimal)
  end

  def self.with_salary_max(amount)
    decimal = decimal_amount(amount)
    return all if decimal.nil?

    where("reporting_amount <= ?", decimal)
  end

  def self.integer_identifier(value)
    return nil if value.blank?

    Integer(value, 10)
  rescue ArgumentError, TypeError
    nil
  end

  def self.decimal_amount(value)
    return nil if value.blank?

    decimal = BigDecimal(value.to_s)
    decimal.finite? ? decimal : nil
  rescue ArgumentError
    nil
  end

  validates :employee_number, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hire_date, presence: true
  validates :termination_date, presence: true, if: :terminated?
  validates :termination_date, absence: true, unless: :terminated?

  validate :employment_level_must_apply_to_job_title
  validate :job_title_must_belong_to_department
  validate :termination_date_not_before_hire_date
  validate :manager_cannot_be_self

  private

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
