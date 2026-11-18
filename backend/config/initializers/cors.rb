# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Local Vite (and any other localhost port) can call this API, including the deployed one.
# Add more hosted frontends with CORS_ORIGINS=https://app.example.com,https://other.example.com
local_origins = [
  %r{\Ahttp://localhost:\d+\z},
  %r{\Ahttp://127\.0\.0\.1:\d+\z}
]
hosted_origins = [
  "https://melodic-semolina-9d5ec3.netlify.app"
]
configured_origins = ENV["CORS_ORIGINS"].to_s.split(",").map(&:strip).reject(&:empty?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*local_origins, *hosted_origins, *configured_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: [ "Authorization" ],
      max_age: 600
  end
end
