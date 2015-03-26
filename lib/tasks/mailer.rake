namespace :mailer do
  task ending_projects: :environment do
    ProjectDigest.ending_in_a_week.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :ending_soon, project)
    end
  end

  task three_months_old: :environment do
    ProjectDigest.three_months_old.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :three_months_old, project)
    end
  end

  task kickoff_tomorrow: :environment do
    ProjectDigest.starting_tomorrow.each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :kickoff_tomorrow, project)
    end
  end

  desc 'Email upcoming changes to projects'
  task changes_digest: :environment do
    digest_days = AppConfig.emails.notifications.changes_digest
    ProjectDigest.upcoming_changes(digest_days).each do |project|
      SendMailJob.new.async.perform(ProjectMailer, :upcoming_changes, project, digest_days)
    end
  end
end
