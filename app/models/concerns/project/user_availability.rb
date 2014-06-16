module Project::UserAvailability
  extend ActiveSupport::Concern

  included do
    after_save :check_user_availability
    after_destroy :check_user_availability
  end

  private

  def check_user_availability
    memberships.each do |membership|
      AvailabilityCheckerJob.new.async.perform(membership.user.id)
    end
  end
end
