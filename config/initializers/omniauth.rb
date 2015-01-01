Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["google_oauth2_key"], ENV["google_oauth2_secret"]
end
