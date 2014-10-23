set :output, 'log/whenever.log'

every 1.day, at: '12 am' do
  rake "people:vacation_checker"
end

every 1.minute do
  rake 'mailer:changes_digest'
end
