require 'konf'
AppConfig = Konf.new('config/config.yml', @environment)
changes_digest_day = AppConfig.emails.notifications.changes_digest.weekday.to_sym

set :output, 'log/whenever.log'

every 1.day, at: '12 am' do
  rake 'people:vacation_checker'
end

every changes_digest_day, at: '8 am' do
  rake 'mailer:changes_digest'
end
