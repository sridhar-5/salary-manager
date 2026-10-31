RSpec.describe "Compensation summary", type: :request do
  let(:admin) { create(:admin_user, :compensation_admin) }
  let(:viewer) { create(:admin_user, :viewer) }
  let(:usd) { create(:currency, :dollar) }
  let(:united_states) { create(:country, name: "United States", iso_code: "US", currency: usd) }
  let(:engineering) { create(:department, name: "Engineering") }
  let(:finance) { create(:department, name: "Finance") }
  let(:engineer) { create(:job_title, title: "Software Engineer", department: engineering) }
  let(:analyst) { create(:job_title, title: "Finance Analyst", department: finance) }
  let(:senior) { create(:employment_level, name: "Senior", rank: 40) }

  def create_paid_employee(department_job:, salary:, last_name:)
    employee = create(
      :employee,
      country: united_states,
      job_title: department_job,
      department: department_job.department,
      employment_level: senior,
      last_name:
    )
    create(
      :compensation_record,
      employee:,
      annual_salary: salary,
      effective_from: Date.current - 5,
      currency: usd,
      created_by: admin
    )
    employee
  end

  it "requires authentication" do
    get api_v1_compensation_summary_path

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns reporting-currency aggregates and the highest median groups" do
    create_paid_employee(department_job: engineer, salary: 100_000, last_name: "One")
    create_paid_employee(department_job: engineer, salary: 300_000, last_name: "Two")
    create_paid_employee(department_job: analyst, salary: 200_000, last_name: "Three")

    get api_v1_compensation_summary_path, headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["reporting_currency"]["code"]).to eq("USD")
    expect(body["population"]).to eq(3)
    expect(body["headcount"]).to eq(3)
    expect(body["unconverted_count"]).to eq(0)
    expect(body["total_annual_compensation"].to_d).to eq(600_000)
    expect(body["average_salary"].to_d).to eq(200_000)
    expect(body["median_salary"].to_d).to eq(200_000)
    expect(body["distribution"].sum { |bucket| bucket["count"] }).to eq(3)
    expect(body["insights"]["highest_median_department"]).to include("name" => "Engineering")
    expect(body["insights"]["highest_median_department"]["median"].to_d).to eq(200_000)
    expect(body["by_department"].map { |row| row["name"] }).to contain_exactly("Engineering", "Finance")
    expect(body["filters"]).to include("reporting_currency_id" => usd.id)

    get api_v1_compensation_summary_path, params: { filters: { with_department_id: finance.id } }, headers: auth_headers_for(viewer)

    filtered = response.parsed_body
    expect(filtered["population"]).to eq(1)
    expect(filtered["total_annual_compensation"].to_d).to eq(200_000)
    expect(filtered["filters"]["department_id"]).to eq(finance.id)
  end
end
