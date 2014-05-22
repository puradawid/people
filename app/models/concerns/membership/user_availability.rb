module Membership::UserAvailability
  extend ActiveSupport::Concern

  included do
    after_save :check_user_availability
  end

  private

  def check_user_availability
    AvailabilityCheckerJob.new.async.perform(user.id)
  end
end
