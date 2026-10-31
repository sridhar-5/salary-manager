class CreateJobTitleLevels < ActiveRecord::Migration[8.1]
  def change
    create_table :job_title_levels do |t|
      t.references :job_title, null: false, foreign_key: true, index: false
      t.references :employment_level, null: false, foreign_key: true

      t.timestamps

      t.index [ :job_title_id, :employment_level_id ], unique: true
    end
  end
end
