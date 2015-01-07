class AvailabilityChecker
  def initialize(user)
    @user = user
  end

  def run!
    available = available?
    available_since =
      available.present? ? @available_since : nil

    @user.update_attributes(available: available, available_since: available_since)
  end

  private

  def available?
    return true if has_no_memberships?
    return true if has_non_billable_membership?
    return true if has_memberships_or_projects_with_end_date?
    false
  end

  def has_no_memberships?
    @available_since = Date.today
    current_memberships.empty?
  end

  def has_non_billable_membership?
    @available_since = Date.today
    current_memberships.where(billable: false).present?
  end

  def has_memberships_or_projects_with_end_date?
    memberships = current_memberships_without_continuation
    available_by_membership = memberships.first.try(:ends_at)

    projects = current_projects_with_end
    available_by_project = projects.first.try(:end_at)

    dates = [available_by_membership, available_by_project].reject{ |date| date.blank? }

    @available_since = dates.min
    memberships.present? || projects.present?
  end

  def current_memberships_with_end
    @current_memberships_with_end ||= current_memberships.where(:ends_at.ne => nil)
  end

  def current_memberships
    @current_memberships ||= @user.current_memberships.asc(:ends_at)
  end

  def current_memberships_without_continuation
    current_memberships_with_end.to_a.reject do |membership|
      starts_at = next_memberships.pluck(:starts_at).map(&:to_date)
      starts_at_next = starts_at.map{ |date| date - 1 }
      (starts_at + starts_at_next).include?(membership.ends_at.to_date)
    end
  end

  def next_memberships
    @next_memberships ||= @user.next_memberships.where(billable: true)
  end

  def current_projects
    @project_ids ||= current_memberships.where(billable: true).pluck(:project_id)
    @current_projects ||= Project.where(:_id.in => @project_ids)
  end

  def current_projects_with_end
    @current_projects_with_end ||= current_projects.where(:end_at.ne => nil).asc(:end_at)
  end
end
