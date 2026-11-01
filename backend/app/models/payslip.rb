# == Schema Information
#
# Table name: payslips(Payroll statements issued to an employee for a pay period.)
#
#  id             :bigint           not null, primary key
#  deductions     :decimal(19, 4)   default(0.0), not null
#  gross_pay      :decimal(19, 4)   not null
#  net_pay        :decimal(19, 4)   not null
#  pay_date       :date             not null
#  payslip_number :string(64)       not null
#  period_end     :date             not null
#  period_start   :date             not null
#  status         :enum             default("issued"), not null, enum_type: payslip_status
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  currency_id    :bigint           not null
#  employee_id    :bigint           not null
#
# Indexes
#
#  index_payslips_on_currency_id                   (currency_id)
#  index_payslips_on_employee_id_and_pay_date      (employee_id,pay_date)
#  index_payslips_on_employee_id_and_period_start  (employee_id,period_start) UNIQUE
#  index_payslips_on_payslip_number                (payslip_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (employee_id => employees.id)
#
# Enums
#
#  payslip_status  issued, paid, void
#
class Payslip < ApplicationRecord
  belongs_to :employee
  belongs_to :currency

  enum :status, { issued: "issued", paid: "paid", void: "void" }, validate: true, default: "issued"

  STATUSES = %w[issued paid void].freeze

  scope :newest_first, -> { order(pay_date: :desc, id: :desc) }

  validates :payslip_number, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :period_start, :period_end, :pay_date, presence: true
  validates :period_start, uniqueness: { scope: :employee_id }
  validates :gross_pay, presence: true, numericality: { greater_than: 0 }
  validates :deductions, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :net_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :period_end_not_before_period_start
  validate :pay_date_not_before_period_start
  validate :net_pay_matches_components
  validate :currency_matches_employee_country
  validate :period_overlaps_employment

  private

  def period_end_not_before_period_start
    return if period_end.blank? || period_start.blank?
    return if period_end >= period_start

    errors.add(:period_end, "must be on or after the period start")
  end

  def pay_date_not_before_period_start
    return if pay_date.blank? || period_start.blank?
    return if pay_date >= period_start

    errors.add(:pay_date, "must be on or after the period start")
  end

  def net_pay_matches_components
    return if gross_pay.blank? || deductions.blank? || net_pay.blank?
    return if net_pay.to_d == gross_pay.to_d - deductions.to_d

    errors.add(:net_pay, "must equal gross pay minus deductions")
  end

  def currency_matches_employee_country
    return if currency_id.blank? || employee&.country.blank?
    return if currency_id == employee.country.currency_id

    errors.add(:currency, "must match the employee country currency")
  end

  def period_overlaps_employment
    return if employee.blank? || period_start.blank? || period_end.blank?

    hired_after_period = employee.hire_date.present? && period_end < employee.hire_date
    left_before_period = employee.termination_date.present? && period_start > employee.termination_date
    return unless hired_after_period || left_before_period

    errors.add(:base, "Pay period must overlap the employee's employment")
  end
end
