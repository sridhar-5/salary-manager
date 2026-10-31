class CreateCompensationRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :compensation_records, comment: "Maintain historical salary records. Do not overwrite previous salary amounts." do |t|
      t.references :employee, null: false, foreign_key: true, index: false
      t.decimal :annual_salary, precision: 19, scale: 4, null: false
      t.references :currency, null: false, foreign_key: true
      t.date :effective_from, null: false
      t.date :effective_to
      t.bigint :created_by_id, null: false, comment: "FK to Devise users.id"

      t.timestamps

      t.index [ :employee_id, :effective_from ]
      t.index [ :employee_id, :effective_to ]
    end
  end
end
