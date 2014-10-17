# # You can't run whenever, crontabs on Heroku, need to use scheduler: https://scheduler.heroku.com/dashboard

every 1.day, at: '12 am' do
  return unless Flip.on? :vacations
  rake "people:vacation_checker"
end
