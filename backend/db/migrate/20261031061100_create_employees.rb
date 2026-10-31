class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_enum :employment_status, %w[ active terminated ]

    create_table :employees do |t|
      t.string :employee_number, limit: 50, null: false
      t.string :first_name, limit: 100, null: false
      t.string :last_name, limit: 100, null: false
      t.string :email, limit: 255, null: false

      t.references :country, null: false, foreign_key: true, index: false
      t.references :department, null: false, foreign_key: true, index: false
      t.references :job_title, null: false, foreign_key: true, index: false
      t.references :employment_level, null: false, foreign_key: true
      t.references :manager, null: true, foreign_key: { to_table: :employees }

      t.enum :employment_status, enum_type: :employment_status, null: false
      t.date :hire_date, null: false
      t.date :termination_date

      t.timestamps

      t.index :employee_number, unique: true
      t.index :email, unique: true
      t.index [ :country_id, :department_id ]
      t.index [ :department_id, :job_title_id ]
      t.index :employment_status
    end
  end
end
