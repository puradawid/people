class UserDecorator < Draper::Decorator

  # 60 seconds * 60 minutes * 24 hours * 30.44 days in a month on average
  DAYS_IN_MONTH = 60 * 60 * 24 * 30.44

  decorates :user
  decorates_association :memberships, scope: :only_active
  delegate_all

  def as_row
    [model.last_name, model.first_name, model.role, model.location]
  end

  def project_names
    model.memberships.map { |m| m.project.name }.uniq
  end

  def name
    "#{last_name} #{first_name}"
  end

  def link
    h.link_to name, object
  end

  def gravatar_image(options = {})
    size = options.delete(:size)
    h.image_tag gravatar_url(size), options
  end

  def days_in_current_team
    team_join_time.nil? ? 0 : (DateTime.now - team_join_time).to_i
  end

  def github_link(options = {})
    if github_connected?
      h.link_to "https://github.com/#{gh_nick}" do
        options[:icon] ? h.fa_icon("github-alt") : gh_nick
      end
    end
  end

  def skype_link
    if skype?
      h.link_to "skype:#{skype}?userinfo" do
        h.fa_icon("skype")
      end
    end
  end

  def availability_string
    (available_since || Date.today) <= Date.today ? 'since now' : available_since
  end

  def check_overlapping(date, membership)
    return false unless membership.starts_at.present? && membership.ends_at.present?
    membership.starts_at.to_date <= date && membership.ends_at.to_date > date
  end

  def check_current_membership_date
    next_membership_end_date.present? && next_membership_end_date < current_membership_end_date
  end

  def current_project_end_date
    current_project.try(:end_at).to_date if current_project.try(:end_at).present?
  end

  def current_membership_end_date
    current_memberships.last.try(:ends_at)
  end

  def next_membership_end_date
    next_memberships.last.try(:ends_at)
  end

  def next_membership_start_date
    next_memberships.last.try(:starts_at)
  end

  def last_membership_end_date
    last_membership.try(:ends_at).to_date if last_membership.try(:ends_at).present?
  end

  def info
    projects = project_names.join(', ')
    name + "\n" + phone_number + "\n" + email + "\n" + skype_nick + "\n" + projects
  end

  def skype_nick
    @skype_nick ||= skype.presence || 'No skype'
  end

  def phone_number
    @phone_number ||= phone.presence || 'No phone'
  end

  def abilities_names
    abilities.map(&:name)
  end

  def archived_projects
    memberships_by_project.select{ |project, _membership| project.archived?}
      .sort_by { |_project, memberships| memberships.first.starts_at }
  end

  def unarchived_projects
    memberships_by_project.select{ |project, _membership| !project.archived? && actual(project) }
      .sort_by { |_project, memberships| memberships.first.starts_at }
  end

  def memberships_by_project
    user_membership_repository.items.by_starts_at.group_by(&:project_id).each_with_object({}) do
      |data, memo|
      memberships = data[1]
      project = Project.find(data[0])
      memo[project] = MembershipDecorator.decorate_collection memberships
    end
  end

  def months_in_current_project
    longest_current_membership = current_memberships.min_by { |m| m.starts_at }
    return 0 if longest_current_membership.nil?
    (Time.now - longest_current_membership.starts_at.to_time) / DAYS_IN_MONTH
  end

  def flat_memberships
    membs_grouped = model.memberships.group_by { |m| m.project.api_slug }
    membs_grouped.each do |slug, membs|
      membs_grouped[slug] = {
        starts_at: (membs.map(&:starts_at).include?(nil) ? nil : membs.map(&:starts_at).compact.min),
        ends_at: (membs.map(&:ends_at).include?(nil) ? nil : membs.map(&:ends_at).compact.max),
        role: (membs.map { |memb| memb.role.try(:name) }).last
      }
    end
  end


  def next_projects_json
    @next_projects_json ||= projects_json(next_memberships)
  end

  def booked_projects_json
    @booked_projects_json ||= projects_json(booked_memberships)
  end

  def potential_projects_json
    @potential_projects_json ||= projects_json(potential_memberships)
  end

  def current_projects_json
    current_projects_with_memberships_json.map{ |p| p[:project] }
  end

  def current_projects_with_memberships_json
    @current_projects_with_memberships_json ||= projects_json(current_memberships)
  end

  def projects_json(membership)
    membership.map { |c_ms| { project: c_ms.project, billable: c_ms.billable, membership: c_ms } }
  end

  private

  def proper_date(date)
    date.present? && date.to_date < 4.weeks.from_now
  end

  def oncoming_membership_date_check(date)
    return unless date.present?
    next_day = date + 1.days
    oncoming_membership = next_memberships.where(starts_at: next_day).asc(:ends_at).last
    unless oncoming_membership.present?
      oncoming_membership = next_memberships.where(starts_at: date).last
    end
    return date if oncoming_membership.present? && !proper_date(oncoming_membership.ends_at)
    oncoming_membership_date = oncoming_membership.ends_at.to_date if oncoming_membership.present?
    oncoming_membership_date_check(oncoming_membership_date) || oncoming_membership_date
  end

  def dates_check(date)
    oncoming_membership_end_date = oncoming_membership_date_check(date)
    if proper_date(oncoming_membership_end_date)
      oncoming_membership_end_date
    else
      date
    end
  end

  def project_end_date
    return current_project_end_date if proper_date(current_project_end_date) &&
      current_project_end_date >= Time.now
  end

  def actual(project)
    return true unless project.end_at.present?
    project.end_at > Time.now
  end
end
