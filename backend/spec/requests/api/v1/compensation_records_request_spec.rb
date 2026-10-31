RSpec.describe "Compensation records API", type: :request do
  let(:admin) { create(:admin_user, :compensation_admin) }
  let(:viewer) { create(:admin_user, :viewer) }
  let(:employee) { create(:employee) }

  it "closes the previous open record and returns who created the new salary" do
    previous = create(
      :compensation_record,
      employee:,
      annual_salary: 80_000,
      effective_from: Date.current - 30,
      created_by: admin
    )

    post api_v1_employee_compensation_records_path(employee),
      params: { compensation_record: { annual_salary: 95_000, effective_from: Date.current } },
      headers: auth_headers_for(admin),
      as: :json

    expect(response).to have_http_status(:created)
    body = response.parsed_body["compensation_record"]
    expect(body["annual_salary"].to_d).to eq(95_000)
    expect(body["currency"]["code"]).to eq(employee.country.currency.code)
    expect(body["created_by"]).to eq("id" => admin.id, "email" => admin.email)
    expect(previous.reload.effective_to).to eq(Date.current - 1.day)
    expect(body["audit_events"].map { |event| event["event"] }).to include("create")
  end

  it "records an audit event when the effective end date changes" do
    record = create(
      :compensation_record,
      employee:,
      effective_from: Date.current - 10,
      created_by: admin
    )

    patch api_v1_employee_compensation_record_path(employee, record),
      params: { compensation_record: { effective_to: Date.current } },
      headers: auth_headers_for(admin),
      as: :json

    expect(response).to have_http_status(:ok)

    get api_v1_employee_compensation_records_path(employee), headers: auth_headers_for(admin)

    events = response.parsed_body["compensation_records"].sole["audit_events"]
    update = events.find { |event| event["event"] == "update" }
    expect(update["whodunnit_email"]).to eq(admin.email)
    expect(update["changes"]).to have_key("effective_to")
  end

  it "rejects changes to the salary amount" do
    record = create(:compensation_record, employee:, created_by: admin)

    patch api_v1_employee_compensation_record_path(employee, record),
      params: { compensation_record: { annual_salary: 10 } },
      headers: auth_headers_for(admin),
      as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["errors"]).to have_key("annual_salary")
  end

  it "forbids a viewer from creating compensation" do
    post api_v1_employee_compensation_records_path(employee),
      params: { compensation_record: { annual_salary: 90_000, effective_from: Date.current } },
      headers: auth_headers_for(viewer),
      as: :json

    expect(response).to have_http_status(:forbidden)
  end
end