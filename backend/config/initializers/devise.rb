# frozen_string_literal: true

require "devise/orm/active_record"

Devise.setup do |config|
  config.mailer_sender = "please-change-me@example.com"
  config.navigational_formats = []
  config.skip_session_storage = [ :http_auth, :params_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  config.last_attempt_warning = false

  config.warden do |manager|
    manager.failure_app = API::FailureApp
  end

  jwt_secret = ENV["DEVISE_JWT_SECRET_KEY"].presence
  if jwt_secret.blank?
    raise "DEVISE_JWT_SECRET_KEY is required" unless Rails.env.local?

    jwt_secret = Rails.application.secret_key_base
  end

  config.jwt do |jwt|
    jwt.secret = jwt_secret
    jwt.expiration_time = 8.hours.to_i
    jwt.dispatch_requests = []
    jwt.revocation_requests = []
  end
end
