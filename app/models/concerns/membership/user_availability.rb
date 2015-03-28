module Membership::UserAvailability
  extend Shared::Availability

  private

  def check_user_availability
    AvailabilityCheckerJob.new.async.perform(user.id)
  end
end
