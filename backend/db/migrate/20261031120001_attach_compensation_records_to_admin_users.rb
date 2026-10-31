class AttachCompensationRecordsToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up { execute "DELETE FROM compensation_records" }
    end

    add_index :compensation_records, :created_by_id
    add_foreign_key :compensation_records, :admin_users, column: :created_by_id
    change_column_comment :compensation_records, :created_by_id, "Admin who created the compensation record"

    add_check_constraint :compensation_records,
      "annual_salary > 0",
      name: "compensation_records_annual_salary_positive"
    add_check_constraint :compensation_records,
      "effective_to IS NULL OR effective_to >= effective_from",
      name: "compensation_records_effective_range"
  end
end
