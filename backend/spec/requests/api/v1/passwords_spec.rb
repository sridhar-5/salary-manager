RSpec.describe "Admin passwords", type: :request do
  let(:admin) { create(:admin_user, :viewer, password: "password123", password_confirmation: "password123") }

  it "changes the password when the current password matches" do
    patch api_v1_password_path,
      params: { current_password: "password123", password: "new-password", password_confirmation: "new-password" },
      headers: auth_headers_for(admin),
      as: :json

    expect(response).to have_http_status(:ok)
    expect(admin.reload.valid_password?("new-password")).to be(true)
  end

  it "rejects a wrong current password" do
    patch api_v1_password_path,
      params: { current_password: "nope", password: "new-password", password_confirmation: "new-password" },
      headers: auth_headers_for(admin),
      as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(admin.reload.valid_password?("password123")).to be(true)
  end
end
