class CreatePayslips < ActiveRecord::Migration[8.1]
  def change
    create_enum :payslip_status, %w[ issued paid void ]

    create_table :payslips, comment: "Payroll statements issued to an employee for a pay period." do |t|
      t.references :employee, null: false, foreign_key: true, index: false
      t.references :currency, null: false, foreign_key: true
      t.string :payslip_number, limit: 64, null: false
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.date :pay_date, null: false
      t.decimal :gross_pay, precision: 19, scale: 4, null: false
      t.decimal :deductions, precision: 19, scale: 4, null: false, default: 0
      t.decimal :net_pay, precision: 19, scale: 4, null: false
      t.enum :status, enum_type: :payslip_status, null: false, default: "issued"

      t.timestamps

      t.index :payslip_number, unique: true
      t.index [ :employee_id, :period_start ], unique: true
      t.index [ :employee_id, :pay_date ]
    end

    add_check_constraint :payslips, "gross_pay > 0", name: "payslips_gross_pay_positive"
    add_check_constraint :payslips, "deductions >= 0", name: "payslips_deductions_non_negative"
    add_check_constraint :payslips, "net_pay >= 0", name: "payslips_net_pay_non_negative"
    add_check_constraint :payslips,
      "net_pay = gross_pay - deductions",
      name: "payslips_net_equals_gross_minus_deductions"
    add_check_constraint :payslips, "period_end >= period_start", name: "payslips_period_range"
    add_check_constraint :payslips, "pay_date >= period_start", name: "payslips_pay_date_on_or_after_period_start"
  end
end
