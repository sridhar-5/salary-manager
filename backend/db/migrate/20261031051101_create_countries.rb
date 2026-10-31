class CreateCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :countries do |t|
      t.string :name, limit: 100, null: false
      t.string :iso_code, limit: 2, null: false, comment: "ISO 3166-1 alpha-2"
      t.references :currency, null: false, foreign_key: true

      t.index :iso_code, unique: true
    end
  end
end
