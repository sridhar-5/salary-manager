RSpec.describe Payslip, type: :model do
  subject { build(:payslip) }

  it { is_expected.to belong_to(:employee) }
  it { is_expected.to belong_to(:currency) }

  it { is_expected.to define_enum_for(:status).with_values(issued: "issued", paid: "paid", void: "void").backed_by_column_of_type(:enum) }

  it { is_expected.to validate_presence_of(:payslip_number) }
  it { is_expected.to validate_length_of(:payslip_number).is_at_most(64) }
  it { is_expected.to validate_presence_of(:period_start) }
  it { is_expected.to validate_presence_of(:period_end) }
  it { is_expected.to validate_presence_of(:pay_date) }
  it { is_expected.to validate_presence_of(:gross_pay) }
  it { is_expected.to validate_numericality_of(:gross_pay).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:deductions) }
  it { is_expected.to validate_numericality_of(:deductions).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_presence_of(:net_pay) }
  it { is_expected.to validate_numericality_of(:net_pay).is_greater_than_or_equal_to(0) }

  it "requires a unique payslip number" do
    existing = create(:payslip)
    duplicate = build(:payslip, payslip_number: existing.payslip_number)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:payslip_number]).to include("has already been taken")
  end

  it "allows only one payslip per employee and period start" do
    existing = create(:payslip)
    duplicate = build(:payslip, employee: existing.employee, period_start: existing.period_start)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:period_start]).to include("has already been taken")
  end

  it "does not allow the period to end before it starts" do
    payslip = build(:payslip, period_start: Date.current, period_end: Date.yesterday, pay_date: Date.current)

    expect(payslip).not_to be_valid
    expect(payslip.errors[:period_end]).to include("must be on or after the period start")
  end

  it "does not allow a pay date before the period starts" do
    payslip = build(
      :payslip,
      period_start: Date.current.beginning_of_month,
      period_end: Date.current.end_of_month,
      pay_date: Date.current.beginning_of_month - 1.day
    )

    expect(payslip).not_to be_valid
    expect(payslip.errors[:pay_date]).to include("must be on or after the period start")
  end

  it "requires net pay to equal gross pay minus deductions" do
    payslip = build(:payslip, gross_pay: 10_000, deductions: 2_000, net_pay: 7_000)

    expect(payslip).not_to be_valid
    expect(payslip.errors[:net_pay]).to include("must equal gross pay minus deductions")
  end

  it "requires the employee country currency" do
    payslip = build(:payslip, currency: create(:currency))

    expect(payslip).not_to be_valid
    expect(payslip.errors[:currency]).to include("must match the employee country currency")
  end

  it "requires the pay period to overlap employment" do
    employee = create(:employee, hire_date: Date.current)
    payslip = build(
      :payslip,
      employee:,
      period_start: Date.current.prev_month.beginning_of_month,
      period_end: Date.current.prev_month.end_of_month,
      pay_date: Date.current.prev_month.end_of_month
    )

    expect(payslip).not_to be_valid
    expect(payslip.errors[:base]).to include("Pay period must overlap the employee's employment")
  end
end
