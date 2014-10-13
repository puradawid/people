require 'net/ssh/proxy/command'
server ENV['PRODUCTION_SERVER'], user: ENV['PRODUCTION_USER'], roles: %w{web app db}
set :branch, 'master'
