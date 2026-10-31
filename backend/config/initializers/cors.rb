# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

cors_origins = ENV["CORS_ORIGINS"].to_s.split(",").map(&:strip).reject(&:empty?)
if cors_origins.empty? && Rails.env.local?
  cors_origins = %w[http://localhost:3000 http://localhost:5173 http://127.0.0.1:5173]
end

if cors_origins.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*cors_origins)

      resource "*",
        headers: :any,
        methods: %i[get post put patch delete options head],
        expose: [ "Authorization" ],
        max_age: 600
    end
  end
end
