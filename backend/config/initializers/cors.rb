# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Local Vite (and any other localhost port) can call this API, including the deployed one.
# Add a hosted frontend origin with CORS_ORIGINS=https://app.example.com
local_origins = [
  %r{\Ahttp://localhost:\d+\z},
  %r{\Ahttp://127\.0\.0\.1:\d+\z}
]
configured_origins = ENV["CORS_ORIGINS"].to_s.split(",").map(&:strip).reject(&:empty?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*local_origins, *configured_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: [ "Authorization" ],
      max_age: 600
  end
end
