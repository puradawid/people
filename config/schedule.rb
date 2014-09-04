# # You can't run whenever, crontabs on Heroku, need to use scheduler: https://scheduler.heroku.com/dashboard

every 1.day, at: '12 am' do
  rake "people:vacation_checker"
end
