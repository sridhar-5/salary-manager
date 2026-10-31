RSpec.describe "Domain authorization", type: :request do
  let(:viewer) { create(:admin_user, :viewer) }
  let(:compensation_admin) { create(:admin_user, :compensation_admin) }
  let(:super_admin) { create(:admin_user, :super_admin) }

  it "rejects an unauthenticated employee index" do
    get api_v1_employees_path

    expect(response).to have_http_status(:unauthorized)
  end

  it "lets a viewer read employees and forbids creating them" do
    create(:employee)

    get api_v1_employees_path, headers: auth_headers_for(viewer)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["employees"].size).to eq(1)

    post api_v1_employees_path, params: { employee: { first_name: "Ada" } }, headers: auth_headers_for(viewer), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "lets a compensation admin create an employee but not a country" do
    country = create(:country)
    department = create(:department)
    job_title = create(:job_title, department:)
    employment_level = create(:employment_level)
    create(:job_title_level, job_title:, employment_level:)

    post api_v1_employees_path,
      params: {
        employee: {
          employee_number: "EMP9001",
          first_name: "Grace",
          last_name: "Hopper",
          email: "grace@example.com",
          country_id: country.id,
          department_id: department.id,
          job_title_id: job_title.id,
          employment_level_id: employment_level.id,
          employment_status: "active",
          hire_date: Date.current
        }
      },
      headers: auth_headers_for(compensation_admin),
      as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["employee"]["email"]).to eq("grace@example.com")

    post api_v1_countries_path,
      params: { country: { name: "Canada", iso_code: "CA", currency_id: country.currency_id } },
      headers: auth_headers_for(compensation_admin),
      as: :json

    expect(response).to have_http_status(:forbidden)
  end

  it "lets a super admin create reference data" do
    currency = create(:currency)

    post api_v1_countries_path,
      params: { country: { name: "Canada", iso_code: "CA", currency_id: currency.id } },
      headers: auth_headers_for(super_admin),
      as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["country"]["iso_code"]).to eq("CA")
  end

  it "records the acting admin on a new compensation record" do
    employee = create(:employee)

    post api_v1_employee_compensation_records_path(employee),
      params: { compensation_record: { annual_salary: 90_000, effective_from: Date.current } },
      headers: auth_headers_for(compensation_admin),
      as: :json

    expect(response).to have_http_status(:created)
    record = employee.compensation_records.sole
    expect(record.created_by).to eq(compensation_admin)
    expect(record.currency).to eq(employee.country.currency)
    expect(record.versions.sole.whodunnit).to eq(compensation_admin.id.to_s)
  end

  it "exposes the Authorization header to browser clients" do
    get "/up", headers: { "Origin" => "http://localhost:3000" }

    expect(response.headers["Access-Control-Expose-Headers"]).to include("Authorization")
  end
end
