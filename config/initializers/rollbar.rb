require 'rollbar/rails'

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN'] || AppConfig.rollbar.access_token
  config.exception_level_filters.merge!('Mongoid::DocumentNotFound' => 'ignore', 'ActionController::RoutingError' => 'ignore')

  if Rails.env.test? || Rails.env.development?
     config.enabled = false
  end
end
