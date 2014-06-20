namespace :mailer do
  task ending_projects: :environment do
    Project.ending_in_a_week.each do |project|
      ProjectMailer.ending_soon(project).deliver
    end
  end

  task three_months_old: :environment do
    Project.three_months_old.each do |project|
      ProjectMailer.three_months_old(project).deliver
    end
  end

  task kickoff_tomorrow: :environment do
    Project.kickoff_tomorrow.each do |project|
      ProjectMailer.kickoff_tomorrow(project).deliver
    end
  end
end
