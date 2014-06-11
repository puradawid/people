class AvailabilityChecker
  def initialize user
    @user = user
  end

  def run!
    @user.update_attributes available: available?
  end

  private

  def available?
    bilable_count = billable_memberships
    bilable_count == 0 || bilable_count <= finishing_work
  end

  def billable_memberships
    @user.next_memberships.select { |m| m.billable == true }.count + @user.current_memberships.select { |m| m.billable == true }.count
  end

  def finishing_work
    uniquee_projects = (projects_with_end_date.compact + ending_projects + ending_memberships.map(&:project)).uniq
    uniquee_projects.count
  end

  def projects_with_end_date
    current_projects.select { |p| p.end_at.present? }
  end

  def ending_memberships
    @user.current_memberships.select { |p| p.billable == true && p.ends_at < 1.week.from_now if p.ends_at.present? }
  end

  def ending_projects
    current_projects.select { |p| p.end_at < 1.week.from_now if p.end_at.present? }
  end

  def current_projects
    @user.current_memberships.select { |m| m.billable == true }.map(&:project)
  end
end
