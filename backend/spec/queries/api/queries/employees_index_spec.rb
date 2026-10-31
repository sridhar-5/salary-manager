RSpec.describe API::Queries::EmployeesIndex do
  subject(:query) { described_class.new(params, ability: AdminUserAbility.new(admin)) }

  let(:admin) { create(:admin_user, :compensation_admin) }
  let(:usd) { create(:currency, :dollar) }
  let(:united_states) { create(:country, name: "United States", iso_code: "US", currency: usd) }
  let(:engineering) { create(:department, name: "Engineering") }
  let(:finance) { create(:department, name: "Finance") }
  let(:engineer) { create(:job_title, title: "Software Engineer", department: engineering) }
  let(:analyst) { create(:job_title, title: "Finance Analyst", department: finance) }
  let(:senior) { create(:employment_level, name: "Senior", rank: 30) }

  def create_paid_employee(job_title:, salary:, last_name:, status: :active)
    employee = create(
      :employee,
      country: united_states,
      job_title:,
      department: job_title.department,
      employment_level: senior,
      last_name:,
      employment_status: status,
      termination_date: status == :terminated ? Date.current : nil
    )
    create(
      :compensation_record,
      employee:,
      annual_salary: salary,
      effective_from: Date.current - 10,
      currency: usd,
      created_by: admin
    )
    employee
  end

  describe "#records" do
    subject do
      query.call
      query.records
    end

    context "with a status filter" do
      let(:params) { { page: 1, filters: { with_employment_status: "active" } } }

      it "returns only rows with that status" do
        matching = create_paid_employee(job_title: engineer, salary: 100_000, last_name: "Open")
        create_paid_employee(job_title: engineer, salary: 90_000, last_name: "Closed", status: :terminated)

        expect(subject).to match_array([ matching ])
      end
    end

    context "with pagination" do
      let(:params) { { page: 2, limit: 1 } }

      it "returns the requested page" do
        create_paid_employee(job_title: engineer, salary: 100_000, last_name: "Alpha")
        create_paid_employee(job_title: engineer, salary: 100_000, last_name: "Bravo")

        expect(subject.size).to eq(1)
        expect(subject.map(&:last_name)).to eq([ "Bravo" ])
      end
    end
  end
end
