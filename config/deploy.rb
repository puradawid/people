lock '3.2.1'

set :application, "people"
set :repo_url,  "ssh://git@github.com/netguru/people.git"
set :deploy_to, ENV['DEPLOY_PATH']

set :linked_files, %w{nginx.production.people.conf nginx.staging.people.conf config/mongoid.yml config/sec_config.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle }
