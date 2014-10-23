every 1.day, at: '12 am' do
  rake "people:vacation_checker"
end

every :monday, at: '8am' do
  rake 'mailer:changes_digest'
end
