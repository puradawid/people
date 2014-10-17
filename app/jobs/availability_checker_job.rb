class AvailabilityCheckerJob
  include SuckerPunch::Job

  def perform user_id
    user = User.where(id: user_id).first
    AvailabilityChecker.new(user).run! if user.present?
  end
end
