Devise.setup do |config|
  config.secret_key = 'a4137e53d2076f61852675dd378015a0a50e7c210c1e851fb80a49f3304171bcc9665d89e83f1d305e8ade80e2ffa2f50c6bbf8d096f71f216c54dc6b5308ab9'

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/mongoid'
  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :get

  require 'omniauth-google-oauth2'

  config.omniauth(
    :google_oauth2, AppConfig.google_client_id, AppConfig.google_secret,
    { access_type: "offline", approval_prompt: "", hd: AppConfig.google_domain,
      scope: 'userinfo.email, userinfo.profile, calendar'
    }
  )

  config.omniauth(
    :github,
    AppConfig.github_client_id,
    AppConfig.github_secret,
    { scope: '' }
  )
end
