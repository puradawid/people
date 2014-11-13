# Since Rails is not initialized in whenever job file
# it's necessary to manualy require config yml files
ENV['RAILS_ENV'] ||= @environment
require './config/preinitializer'

changes_digest_day = AppConfig.emails.notifications.changes_digest.weekday.to_sym

set :output, 'log/whenever.log'

every 1.day, at: '12 am' do
  rake 'people:vacation_checker'
end

every changes_digest_day, at: '8 am' do
  rake 'mailer:changes_digest'
end

every 1.day, at: '8 am' do
  rake 'people:available_checker'
  rake 'people:gravatars_download'
end
