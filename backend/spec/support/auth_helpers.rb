module AuthHelpers
  def auth_headers_for(admin_user)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(admin_user, :admin_user, nil)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
