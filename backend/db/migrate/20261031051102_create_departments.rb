class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :name, limit: 100, null: false
      t.text :description

      t.timestamps

      t.index :name, unique: true
    end
  end
end
