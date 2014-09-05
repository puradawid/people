class AvailabilityChecker
  def initialize user
    @user = user
  end

  def run!
    @user.update_attributes available: available?
  end

  private

  def on_vacation
    if @user.vacation.present?
      (@user.vacation.starts_at.to_date <= Time.now) && (@user.vacation.ends_at.to_date >= Time.now)
    end
  end

  def available?
    bilable_count = billable_memberships
    (bilable_count == 0 || bilable_count <= finishing_work) && !on_vacation
  end

  def billable_memberships
    @user.current_memberships.select { |m| m.billable == true }.count
  end

  def finishing_work
    uniquee_projects = ( ending_projects + ending_memberships.map(&:project)).uniq
    uniquee_projects.count
  end

  def ending_memberships
    @user.current_memberships.select { |p| p.billable == true && p.ends_at < 2.week.from_now if p.ends_at.present? }
  end

  def ending_projects
    current_projects.select { |p| p.end_at < 2.week.from_now if p.end_at.present? }
  end

  def current_projects
    @user.current_memberships.select { |m| m.billable == true }.map(&:project)
  end
end
