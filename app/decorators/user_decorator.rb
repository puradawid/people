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
      h.link_to "https://github.com/#{gh_nick}", title: gh_nick do
        options[:icon] ? h.fa_icon("github-alt") : gh_nick
      end
    end
  end

  def skype_link
    if skype?
      h.link_to "skype:#{skype}?userinfo", title: skype do
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
end
