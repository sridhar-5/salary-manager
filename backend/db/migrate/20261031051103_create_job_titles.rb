class CreateJobTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :job_titles do |t|
      t.string :title, limit: 150, null: false
      t.text :description

      t.timestamps

      t.index :title, unique: true
    end
  end
end
