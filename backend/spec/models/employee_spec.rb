RSpec.describe Employee, type: :model do
  subject { build(:employee) }

  it { is_expected.to belong_to(:country) }
  it { is_expected.to belong_to(:department) }
  it { is_expected.to belong_to(:job_title) }
  it { is_expected.to belong_to(:employment_level) }
  it { is_expected.to belong_to(:manager).class_name("Employee").optional }
  it { is_expected.to have_many(:direct_reports).class_name("Employee").dependent(:nullify) }

  it { is_expected.to define_enum_for(:employment_status).with_values(active: "active", terminated: "terminated").backed_by_column_of_type(:enum) }

  it { is_expected.to validate_presence_of(:employee_number) }
  it { is_expected.to validate_length_of(:employee_number).is_at_most(50) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_most(100) }

  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(100) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_length_of(:email).is_at_most(255) }

  it { is_expected.to validate_presence_of(:hire_date) }

  it { is_expected.to allow_value("ada@example.com").for(:email) }
  it { is_expected.not_to allow_value("not-an-email").for(:email) }

  describe "uniqueness" do
    subject { create(:employee) }

    it { is_expected.to validate_uniqueness_of(:employee_number) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe "employment level applicability" do
    it "is invalid when the level is not linked to the job title" do
      employee = create(:employee)
      employee.employment_level = create(:employment_level)

      expect(employee).not_to be_valid
      expect(employee.errors[:employment_level]).to include("is not applicable to the selected job title")
    end
  end

  describe "termination date" do
    it "requires a termination date when terminated" do
      employee = build(:employee, :terminated, termination_date: nil)

      expect(employee).not_to be_valid
      expect(employee.errors[:termination_date]).to include("can't be blank")
    end

    it "forbids a termination date when active" do
      employee = build(:employee, termination_date: Date.current)

      expect(employee).not_to be_valid
      expect(employee.errors[:termination_date]).to include("must be blank")
    end

    it "does not allow a termination date before the hire date" do
      employee = build(:employee, :terminated, hire_date: Date.current, termination_date: Date.yesterday)

      expect(employee).not_to be_valid
      expect(employee.errors[:termination_date]).to include("must be on or after the hire date")
    end
  end

  describe "manager" do
    it "cannot be the employee" do
      employee = create(:employee)
      employee.manager = employee

      expect(employee).not_to be_valid
      expect(employee.errors[:manager]).to include("cannot be the employee")
    end
  end
end
