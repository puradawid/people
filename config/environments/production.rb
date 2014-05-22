Hrguru::Application.configure do

  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false

  config.action_controller.perform_caching = true

  config.serve_static_assets = false

  config.assets.compile = false

  config.assets.compress = true

  config.assets.digest = true

  config.assets.version = '1.0'

  config.log_level = :info

  config.i18n.fallbacks = true

  config.assets.initialize_on_precompile = false

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => AppConfig.sendgrid.login,
    :password       => AppConfig.sendgrid.password,
    :domain         => AppConfig.sendgrid.domain,
    :enable_starttls_auto => true
  }
end
