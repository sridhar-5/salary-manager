# == Schema Information
#
# Table name: compensation_records(Maintain historical salary records. Do not overwrite previous salary amounts.)
#
#  id                                                       :bigint           not null, primary key
#  annual_salary                                            :decimal(19, 4)   not null
#  effective_from                                           :date             not null
#  effective_to                                             :date
#  created_at                                               :datetime         not null
#  updated_at                                               :datetime         not null
#  created_by_id(Admin who created the compensation record) :bigint           not null
#  currency_id                                              :bigint           not null
#  employee_id                                              :bigint           not null
#
# Indexes
#
#  index_compensation_records_on_created_by_id                   (created_by_id)
#  index_compensation_records_on_currency_id                     (currency_id)
#  index_compensation_records_on_employee_id_and_effective_from  (employee_id,effective_from)
#  index_compensation_records_on_employee_id_and_effective_to    (employee_id,effective_to)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => admin_users.id)
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (employee_id => employees.id)
#
class CompensationRecord < ApplicationRecord
  IMMUTABLE_ATTRIBUTES = %w[employee_id annual_salary currency_id effective_from created_by_id].freeze

  has_paper_trail

  belongs_to :employee
  belongs_to :currency
  belongs_to :created_by, class_name: "AdminUser"

  validates :annual_salary, presence: true, numericality: { greater_than: 0 }
  validates :effective_from, presence: true
  validates :created_by_id, presence: true

  validate :effective_to_not_before_effective_from
  validate :currency_matches_employee_country
  validate :immutable_attributes_not_changed
  before_destroy :prevent_destroy

  private

  def effective_to_not_before_effective_from
    return if effective_to.blank? || effective_from.blank?
    return if effective_to >= effective_from

    errors.add(:effective_to, "must be on or after the effective from date")
  end

  def currency_matches_employee_country
    return if currency_id.blank? || employee&.country.blank?
    return if currency_id == employee.country.currency_id

    errors.add(:currency, "must match the employee country currency")
  end

  def immutable_attributes_not_changed
    return if new_record?

    changed_immutable = IMMUTABLE_ATTRIBUTES & changed
    return if changed_immutable.empty?

    changed_immutable.each do |attribute|
      errors.add(attribute, "cannot be changed; create a new compensation record instead")
    end
  end

  def prevent_destroy
    errors.add(:base, "Compensation records cannot be deleted")
    throw :abort
  end
end
