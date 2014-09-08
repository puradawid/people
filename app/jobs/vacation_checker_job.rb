class VacationCheckerJob
  include SuckerPunch::Job

  def perform(vacation_id)
    vacation = Vacation.find(vacation_id)
    VacationChecker.new(vacation).check! if vacation.present?
  end
end
