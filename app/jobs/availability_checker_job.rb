class AvailabilityCheckerJob
  include SuckerPunch::Job

  def perform user_id
    user = User.find(user_id)
    AvailabilityChecker.new(user).run! if user.present?
  end
end
