source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '4.0.3'
gem 'rollbar'
gem 'google-analytics-rails'
gem 'newrelic_rpm'

gem 'konf'
gem "heroku-mongo-backup", github: 'alexkravets/heroku-mongo-backup', branch: 'mongoid4'
gem 'fog'

gem 'mongoid', github: 'mongoid/mongoid', ref: '054825f'
gem 'mongoid-paranoia', github: 'simi/mongoid-paranoia'
gem 'mongoid_orderable'
gem 'bson'
gem 'bson_ext'
gem 'moped'
gem 'mongoid-history'
gem 'mongoid_userstamp'
gem 'mongoid_rails_migrations'
gem 'astrails-safe'

gem 'decent_exposure'
gem 'decent_decoration'
gem 'devise'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'draper', '~> 1.3'
gem 'rabl'
gem 'oj'
gem 'sucker_punch', '~> 1.0'

gem 'haml-rails'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer'

gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'js_stack'
gem 'gon'
gem 'simple_form'
gem 'selectize-rails'
gem 'font-awesome-rails'
gem 'messengerjs-rails'

gem 'whenever', require: false
gem 'versionist'

gem 'will_paginate_mongoid'
gem 'will_paginate-bootstrap'

group :staging, :production do
  gem 'rails_12factor'
end

group :development do
  gem 'better_errors'
  gem 'letter_opener'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'xray-rails'
end

group :development, :test do
  gem 'pry'
  gem 'pry-debugger'
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
end
