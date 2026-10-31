RSpec.describe "Employee directory", type: :request do
  let(:admin) { create(:admin_user, :compensation_admin) }
  let(:viewer) { create(:admin_user, :viewer) }
  let(:usd) { create(:currency, :dollar) }
  let(:inr) { create(:currency, code: "INR", name: "Indian Rupee") }
  let(:united_states) { create(:country, name: "United States", iso_code: "US", currency: usd) }
  let(:india) { create(:country, name: "India", iso_code: "IN", currency: inr) }
  let(:engineering) { create(:department, name: "Engineering") }
  let(:finance) { create(:department, name: "Finance") }
  let(:engineer) { create(:job_title, title: "Software Engineer", department: engineering) }
  let(:analyst) { create(:job_title, title: "Finance Analyst", department: finance) }
  let(:senior) { create(:employment_level, name: "Senior", rank: 30) }

  def create_paid_employee(country:, job_title:, salary:, first_name: "Ada", last_name: "Lovelace", status: :active, manager: nil)
    employee = create(
      :employee,
      country:,
      job_title:,
      department: job_title.department,
      employment_level: senior,
      first_name:,
      last_name:,
      employment_status: status,
      termination_date: status == :terminated ? Date.current : nil,
      manager:
    )
    create(
      :compensation_record,
      employee:,
      annual_salary: salary,
      effective_from: Date.current - 10,
      currency: country.currency,
      created_by: admin
    )
    employee
  end

  it "requires authentication" do
    get api_v1_employees_path

    expect(response).to have_http_status(:unauthorized)
  end

  it "searches, filters, converts, and paginates employees" do
    create(
      :exchange_rate,
      base_currency: inr,
      quote_currency: usd,
      rate: BigDecimal("0.012"),
      effective_date: Date.current
    )
    matched = create_paid_employee(
      country: india,
      job_title: engineer,
      salary: 830_000,
      first_name: "Grace",
      last_name: "Hopper"
    )
    create_paid_employee(country: united_states, job_title: analyst, salary: 50_000, last_name: "Low")
    create_paid_employee(country: united_states, job_title: analyst, salary: 180_000, last_name: "High")
    eur = create(:currency, code: "EUR", name: "Euro")
    europe = create(:country, name: "Germany", iso_code: "DE", currency: eur)
    create_paid_employee(country: europe, job_title: engineer, salary: 90_000, last_name: "Unconverted")

    get api_v1_employees_path, params: {
      page: 1,
      limit: 1,
      search: "Grace Hopper"
    }, headers: auth_headers_for(admin)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["employees"].size).to eq(1)
    expect(body["employees"].first["id"]).to eq(matched.id)
    expect(body["employees"].first["country"]["iso_code"]).to eq("IN")
    expect(body["employees"].first["current_compensation"]["currency"]["code"]).to eq("INR")
    expect(body["employees"].first["current_compensation"]["reporting_amount"].to_d).to eq(BigDecimal("9960"))
    expect(body["meta"]).to include(
      "page" => 1,
      "per_page" => 1,
      "total_count" => 1,
      "reporting_currency" => hash_including("code" => "USD")
    )

    get api_v1_employees_path,
      params: {
        filters: {
          with_country_id: united_states.id,
          with_department_id: finance.id,
          with_salary_min: 100_000,
          with_salary_max: 200_000
        }
      },
      headers: auth_headers_for(admin)

    salaries = response.parsed_body["employees"].map { |employee| employee["last_name"] }
    expect(salaries).to eq([ "High" ])

    get api_v1_employees_path, params: { filters: { with_employment_status: "active" } }, headers: auth_headers_for(admin)

    expect(response.parsed_body["meta"]["total_count"]).to eq(4)
    expect(response.parsed_body["meta"]["unconverted_count"]).to eq(1)
  end

  it "returns the second page" do
    create_paid_employee(country: united_states, job_title: engineer, salary: 100_000, last_name: "Alpha")
    create_paid_employee(country: united_states, job_title: engineer, salary: 100_000, last_name: "Bravo")
    create_paid_employee(country: united_states, job_title: engineer, salary: 100_000, last_name: "Charlie")

    get api_v1_employees_path, params: { limit: 2, page: 2 }, headers: auth_headers_for(admin)

    expect(response.parsed_body["employees"].map { |employee| employee["last_name"] }).to eq([ "Charlie" ])
    expect(response.parsed_body["meta"]["total_pages"]).to eq(2)
  end

  it "includes the manager on the employee payload" do
    manager = create_paid_employee(country: united_states, job_title: engineer, salary: 140_000, first_name: "Lin", last_name: "Manager")
    employee = create_paid_employee(
      country: united_states,
      job_title: engineer,
      salary: 110_000,
      last_name: "Report",
      manager:
    )

    get api_v1_employee_path(employee), headers: auth_headers_for(admin)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["employee"]["manager"]).to include(
      "id" => manager.id,
      "first_name" => "Lin",
      "last_name" => "Manager"
    )
  end

  it "lets a viewer read the directory and forbids creating an employee" do
    create_paid_employee(country: united_states, job_title: engineer, salary: 100_000)

    get api_v1_employees_path, params: { page: 1 }, headers: auth_headers_for(viewer)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["meta"]["total_count"]).to eq(1)

    post api_v1_employees_path, params: { employee: { first_name: "No" } }, headers: auth_headers_for(viewer), as: :json
    expect(response).to have_http_status(:forbidden)
  end
end
