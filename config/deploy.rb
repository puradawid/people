lock '3.2.1'

set :application, "people"
set :repo_url,  "git://github.com/netguru/people.git"
set :deploy_to, ENV['DEPLOY_PATH']

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :linked_files, %w{config/mongoid.yml config/sec_config.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle }

load 'lib/tasks/people.rake'
