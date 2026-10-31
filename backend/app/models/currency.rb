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

  validates :code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, presence: true, length: { maximum: 100 }
end
