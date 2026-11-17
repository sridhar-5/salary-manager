# == Schema Information
#
# Table name: exchange_rates(Rate represents one unit of base currency in quote currency.)
#
#  id                :bigint           not null, primary key
#  effective_date    :date             not null
#  rate              :decimal(20, 10)  not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  base_currency_id  :bigint           not null
#  quote_currency_id :bigint           not null
#
# Indexes
#
#  idx_on_base_currency_id_quote_currency_id_effective_30546a8cbe  (base_currency_id,quote_currency_id,effective_date) UNIQUE
#  index_exchange_rates_on_base_currency_id                        (base_currency_id)
#  index_exchange_rates_on_quote_currency_id                       (quote_currency_id)
#
# Foreign Keys
#
#  fk_rails_...  (base_currency_id => currencies.id)
#  fk_rails_...  (quote_currency_id => currencies.id)
#
class ExchangeRate < ApplicationRecord
  belongs_to :base_currency, class_name: "Currency"
  belongs_to :quote_currency, class_name: "Currency"

  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :effective_date, presence: true
  validates :quote_currency_id, uniqueness: { scope: [ :base_currency_id, :effective_date ] }

  def self.latest_usd_quotes(on = Date.current)
    usd_id = Currency.usd.id
    newest = where(base_currency_id: usd_id, effective_date: ..on)
      .group(:quote_currency_id)
      .select(:quote_currency_id, "MAX(exchange_rates.effective_date) AS effective_date")

    where(base_currency_id: usd_id).joins(<<~SQL.squish)
      INNER JOIN (#{newest.to_sql}) latest_rates
        ON latest_rates.quote_currency_id = exchange_rates.quote_currency_id
       AND latest_rates.effective_date = exchange_rates.effective_date
    SQL
  end

  def self.rates_by_quote_currency(on = Date.current)
    latest_usd_quotes(on).each_with_object({}) do |rate, rates|
      rates[rate.quote_currency_id] = rate.rate
    end
  end

  validate :currencies_must_differ

  private

  def currencies_must_differ
    return if base_currency_id.blank? || quote_currency_id.blank?
    return if base_currency_id != quote_currency_id

    errors.add(:quote_currency, "must be different from the base currency")
  end
end
