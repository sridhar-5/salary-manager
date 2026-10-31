# == Schema Information
#
# Table name: currencies
#
#  id                            :bigint           not null, primary key
#  code(ISO 4217: USD, INR, GBP) :string(3)        not null
#  name                          :string(100)      not null
#
# Indexes
#
#  index_currencies_on_code  (code) UNIQUE
#
class Currency < ApplicationRecord
  has_many :countries, dependent: :restrict_with_error
  has_many :compensation_records, dependent: :restrict_with_error
  has_many :salary_bands, dependent: :restrict_with_error
  has_many :base_exchange_rates, class_name: "ExchangeRate", foreign_key: :base_currency_id, inverse_of: :base_currency, dependent: :restrict_with_error
  has_many :quote_exchange_rates, class_name: "ExchangeRate", foreign_key: :quote_currency_id, inverse_of: :quote_currency, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, presence: true, length: { maximum: 100 }
end
