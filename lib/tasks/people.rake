namespace :people do
  desc "Check user availability"
  task :available_checker => :environment do
    roles = Role.technical.to_a
    User.active.roles(roles).each do |user|
      AvailabilityCheckerJob.new.perform(user.id)
    end
  end
end
