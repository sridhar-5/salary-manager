RSpec.describe "Admin sessions", type: :request do
  let(:password) { "password123" }
  let(:admin) { create(:admin_user, :viewer, password:, password_confirmation: password) }

  describe "POST /api/v1/session" do
    it "returns a token for a valid password" do
      post api_v1_session_path, params: { email: admin.email, password: password }, as: :json

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["token"]).to be_present
      expect(body["admin_user"]).to include("id" => admin.id, "email" => admin.email, "roles" => [ "viewer" ])
      expect(admin.reload.sign_in_count).to eq(1)
    end

    it "rejects an unknown email and a wrong password with the same response" do
      post api_v1_session_path, params: { email: "missing@example.com", password: password }, as: :json
      unknown = response.parsed_body

      post api_v1_session_path, params: { email: admin.email, password: "wrong-password" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq(unknown)
      expect(response.parsed_body["error"]).to eq("Invalid email or password")
    end

    it "locks the admin after repeated failures and still returns a generic error" do
      AdminUser.maximum_attempts.times do
        post api_v1_session_path, params: { email: admin.email, password: "wrong-password" }, as: :json
      end

      post api_v1_session_path, params: { email: admin.email, password: password }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Invalid email or password")
      expect(admin.reload).to be_access_locked
    end
  end

  describe "GET /api/v1/session" do
    it "requires a token" do
      get api_v1_session_path

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Unauthorized")
    end

    it "returns the current admin" do
      get api_v1_session_path, headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["admin_user"]["email"]).to eq(admin.email)
    end
  end

  describe "DELETE /api/v1/session" do
    it "revokes the token" do
      headers = auth_headers_for(admin)

      delete api_v1_session_path, headers: headers
      expect(response).to have_http_status(:no_content)

      get api_v1_session_path, headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
