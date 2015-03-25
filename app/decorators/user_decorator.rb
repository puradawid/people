class UserDecorator < Draper::Decorator

  # 60 seconds * 60 minutes * 24 hours * 30.44 days in a month on average
  DAYS_IN_MONTH = 60 * 60 * 24 * 30.44

  decorates :user
  decorates_association :memberships, scope: :only_active
  delegate_all

  def project_names
    model.memberships.map { |m| m.project.name }.uniq
  end

  def name
    "#{last_name} #{first_name}"
  end

  def primary_role_name
    primary_role.present? ? primary_role.name : ''
  end

  def gravatar_image(options = {})
    size = options.delete(:size)
    h.image_tag gravatar_url(size), options
  end

  def github_link(options = {})
    return unless github_connected?

    h.link_to "https://github.com/#{gh_nick}" do
      options[:icon] ? h.fa_icon("github-alt") : gh_nick
    end
  end

  def skype_link
    return unless skype?

    h.link_to "skype:#{skype}?userinfo" do
      h.fa_icon('skype')
    end
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
end
