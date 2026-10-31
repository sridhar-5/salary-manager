class CreateEmploymentLevels < ActiveRecord::Migration[8.1]
  def change
    create_table :employment_levels do |t|
      t.string :name, limit: 100, null: false
      t.integer :rank, null: false

      t.timestamps

      t.index :name, unique: true
    end
  end
end
