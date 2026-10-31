class AddDepartmentToJobTitles < ActiveRecord::Migration[8.1]
  def up
    add_reference :job_titles, :department, foreign_key: true, null: true

    execute <<~SQL.squish
      UPDATE job_titles
      SET department_id = departments.id
      FROM departments
      WHERE job_titles.department_id IS NULL
        AND (
          (job_titles.title IN ('Software Engineer', 'Engineering Manager', 'Product Manager') AND departments.name = 'Engineering')
          OR (job_titles.title = 'People Partner' AND departments.name = 'People')
          OR (job_titles.title = 'Finance Analyst' AND departments.name = 'Finance')
        )
    SQL

    execute <<~SQL.squish
      UPDATE job_titles
      SET department_id = (SELECT id FROM departments ORDER BY id LIMIT 1)
      WHERE department_id IS NULL
    SQL

    if execute("SELECT 1 FROM job_titles WHERE department_id IS NULL LIMIT 1").any?
      raise ActiveRecord::IrreversibleMigration, "job titles exist but no department is available to assign"
    end

    change_column_null :job_titles, :department_id, false
    remove_index :job_titles, :title, unique: true
    add_index :job_titles, [ :department_id, :title ], unique: true
  end

  def down
    remove_index :job_titles, [ :department_id, :title ], unique: true
    add_index :job_titles, :title, unique: true
    remove_reference :job_titles, :department, foreign_key: true
  end
end
