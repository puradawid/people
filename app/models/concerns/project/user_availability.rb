module Project::UserAvailability
  extend Shared::Availability

  private

  def check_user_availability
    memberships.each do |membership|
      AvailabilityCheckerJob.new.async.perform(membership.user.id)
    end
  end
end
