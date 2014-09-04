namespace :people do
  desc "Delete expired vacations"
  task :vacation_checker => :environment do
    Vacation.all.each do |vacation|
      VacationCheckerJob.new.async.perform(vacation.id)
    end
  end
end
