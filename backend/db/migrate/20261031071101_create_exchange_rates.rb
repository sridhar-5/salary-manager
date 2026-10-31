class CreateExchangeRates < ActiveRecord::Migration[8.1]
  def change
    create_table :exchange_rates, comment: "Rate represents one unit of base currency in quote currency." do |t|
      t.references :base_currency, null: false, foreign_key: { to_table: :currencies }
      t.references :quote_currency, null: false, foreign_key: { to_table: :currencies }
      t.decimal :rate, precision: 20, scale: 10, null: false
      t.date :effective_date, null: false

      t.timestamps

      t.index [ :base_currency_id, :quote_currency_id, :effective_date ], unique: true
    end
  end
end
