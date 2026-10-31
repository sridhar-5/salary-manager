class CreateSalaryBands < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_bands, comment: "Defines acceptable compensation ranges for comparable employee groups." do |t|
      t.references :country, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :job_title, null: false, foreign_key: true
      t.references :employment_level, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :min_salary, precision: 19, scale: 4, null: false
      t.decimal :max_salary, precision: 19, scale: 4, null: false
      t.date :effective_from, null: false
      t.date :effective_to

      t.timestamps
    end
  end
end
