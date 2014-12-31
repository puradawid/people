class AvailabilityChecker
  def initialize(user)
    @user = user
  end

  def run!
    @user.update_attributes available: available?
  end

  private

  def available?
    bilable_count = billable_memberships.count
    ((bilable_count == 0 || bilable_count <= finishing_work) && next_memberships_checker)
  end

  def billable_memberships
    @user.current_memberships.asc(:ends_at).select { |m| m.billable == true }
  end

  def next_billable_memberships
    @user.next_memberships.select { |m| m.billable == true }
  end

  def finishing_work
    uniquee_projects = ( ending_projects + ending_memberships.map(&:project)).uniq
    uniquee_projects.count
  end

  def ending_memberships
    @user.current_memberships.select { |p| p.billable == true && p.ends_at < 4.week.from_now if p.ends_at.present? }
  end

  def next_memberships_checker
    return true unless next_billable_memberships.present?
    current_membership_end = billable_memberships.last.ends_at
    next_membership_kickoff = next_billable_memberships.first.starts_at
    current_membership_end + 1.days == next_membership_kickoff && next_membership_kickoff < 4.weeks.from_now
  end

  def ending_projects
    current_projects.select { |p| p.end_at < 4.week.from_now if p.end_at.present? }
  end

  def current_projects
    @user.current_memberships.select { |m| m.billable == true }.map(&:project)
  end
end
