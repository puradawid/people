class UserDecorator < Draper::Decorator

  decorates :user
  decorates_association :memberships, scope: :only_active
  delegate_all
  CSV_HEADERS = ['Last Name', 'First Name', 'Position', 'Location', 'Projects']

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

  def availability
    last_membership_end_date || current_project_end_date
  end

  def current_project_end_date
    current_project.try(:end_at)
  end

  def last_membership_end_date
    last_membership.try(:ends_at)
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
    memberships_by_project.select{ |project, _membership| project.archived? }
      .sort_by { |_project, memberships| memberships.first.starts_at }
  end

  def unarchived_projects
    memberships_by_project.select{ |project, _membership| !project.archived? }
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
    # 60 seconds * 60 minutes * 24 hours * 30.44 days in a month on average
    (Time.now - longest_current_membership.starts_at) / (60*60*24*30.44)
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

end
