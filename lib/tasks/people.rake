namespace :people do
  desc "Check user availability"
  task :available_checker => :environment do
    roles = Role.technical.to_a
    User.active.roles(roles).each do |user|
      AvailabilityCheckerJob.new.perform(user.id)
    end
  end

  desc "Download user's gravatars"
  task gravatars_download: :environment do
    User.pluck(:id).each do |user_id|
      GravatarDownloaderJob.new.perform(user_id)
    end
  end

  desc "Update_primary role"
  task primary_role_update: :environment do
    User.each do |user|
      user.primary_role = user.role
      user.save
    end
  end
end
