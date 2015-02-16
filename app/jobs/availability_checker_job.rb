class AvailabilityCheckerJob
  include SuckerPunch::Job

  def perform(user_id)
    user = User.where(id: user_id).first

    return unless user.present?

    AvailabilityChecker.new(user).run!
  end
end
