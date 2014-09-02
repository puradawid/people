require 'net/ssh/proxy/command'

lock '3.2.1'

set :keep_releases, 5

set :application, "people"

set :rvm_ruby_version, '2.0.0-p353'
set :repo_url,  "git@github.com:netguru/people.git"
set :rails_env, ->{ fetch(:stage) }
set :user, ->{ fetch(:application) }
set :deploy_to, ->{ "/home/#{fetch(:user)}/app" }
set :rvm_type, :system
set :gateway, "people@g.devguru.co"

branches = { production: :master, staging: :master }
set :branch, ->{ branches[fetch(:stage).to_sym].to_s }

set :scm, :git
set :log_level, :info

set :linked_files, %w{config/mongoid.yml config/nginx.staging.people.conf config/nginx.production.people.conf config/sec_config.yml}
set :linked_dirs, %w{bin log tmp}

namespace :deploy do
  task :restart do
    on roles(:app) do
      execute "touch #{current_path}/tmp/restart.txt"
    end
  end
end

after "deploy:publishing", "deploy:restart"
