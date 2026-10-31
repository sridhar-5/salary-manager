# == Schema Information
#
# Table name: countries
#
#  id                           :bigint           not null, primary key
#  iso_code(ISO 3166-1 alpha-2) :string(2)        not null
#  name                         :string(100)      not null
#  currency_id                  :bigint           not null
#
# Indexes
#
#  index_countries_on_currency_id  (currency_id)
#  index_countries_on_iso_code     (iso_code) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#
class Country < ApplicationRecord
  belongs_to :currency
  has_many :employees, dependent: :restrict_with_error
  has_many :salary_bands, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }
  validates :iso_code, presence: true, uniqueness: true, length: { is: 2 }
end
