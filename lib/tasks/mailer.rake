namespace :mailer do
  task ending_projects: :environment do
    Project.ending_in_a_week.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :ending_soon, project)
    end
  end

  task three_months_old: :environment do
    Project.three_months_old.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :three_months_old, project)
    end
  end

  task kickoff_tomorrow: :environment do
    Project.starting_tomorrow.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :kickoff_tomorrow, project)
    end
  end
end
