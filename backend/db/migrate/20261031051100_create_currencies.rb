class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies do |t|
      t.string :code, limit: 3, null: false, comment: "ISO 4217: USD, INR, GBP"
      t.string :name, limit: 100, null: false

      t.index :code, unique: true
    end
  end
end
