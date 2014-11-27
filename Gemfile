source 'https://rubygems.org'
ruby "2.1.5"

gem 'rails', '4.1.8'
gem 'rollbar'
gem 'google-analytics-rails'
gem 'newrelic_rpm'
gem 'google-api-client', require: 'google/api_client'

gem 'konf'
gem "heroku-mongo-backup", github: 'alexkravets/heroku-mongo-backup', branch: 'mongoid4'
gem 'fog'

gem 'mongoid', github: 'mongoid/mongoid'
gem 'mongoid_paranoia', github: 'simi/mongoid_paranoia'
gem 'mongoid_orderable'
gem 'bson'
gem 'bson_ext'
gem 'moped'
gem 'mongoid-history'
gem 'mongoid_userstamp'
gem 'mongoid_rails_migrations'

gem 'dotenv'
gem 'dotenv-deployment'
gem 'decent_exposure'
gem 'decent_decoration'
gem 'lograge', '~> 0.3.0'
gem 'devise'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'draper'
gem 'rabl'
gem 'oj'
gem 'sucker_punch'
gem 'hipchat'
gem 'netguru_theme'

gem 'haml-rails'
gem 'haml_coffee_assets', github: 'netzpirat/haml_coffee_assets'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'therubyracer'
gem 'render_anywhere', require: false

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'
gem 'js_stack'
gem 'gon'
gem 'simple_form', '~> 3.1.0.rc2'
gem 'selectize-rails'
gem 'font-awesome-rails'
gem 'animate-scss'
gem 'messengerjs-rails'

gem 'whenever', require: false
gem 'versionist'
gem 'jquery-cookie-rails'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'mini_magick'
gem 'flip'

gem 'capistrano'
gem 'rvm1-capistrano3', require: false
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-passenger'


gem 'rack-mini-profiler', '~> 0.9.2', require: false

group :staging, :production do
  gem 'rails_12factor'
end

group :development do
  gem 'better_errors'
  gem 'letter_opener'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'xray-rails'
  gem 'bullet', '~> 4.13.2'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'capistrano-rvm', require: false
end

group :test do
  gem 'spork-rails'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'mongoid-rspec'
  gem 'faker'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: false
  gem 'capybara', '~> 2.4.4'
  gem 'webmock'
  gem 'rack_session_access'
  gem 'poltergeist'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
end
