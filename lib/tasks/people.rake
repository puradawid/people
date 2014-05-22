namespace :people do
  task :available_checker => :environment do
    @roles = Role.technical.to_a
    User.active.roles(@roles).each do |user|
      AvailabilityCheckerJob.new.async.perform(user.id)
    end
  end
end
