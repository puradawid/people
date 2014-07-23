class UserDecorator < Draper::Decorator

  decorates :user
  decorates_association :memberships, scope: :only_active
  delegate_all
  CSV_HEADERS = ['First Name', 'Last Name', 'Position', 'Location', 'Projects']

  def as_row
    [model.first_name, model.last_name, model.role, model.location]
  end

  def project_names
    model.memberships.map { |m| m.project.name}.uniq
  end

  def name
    "#{last_name} #{first_name}"
  end

  def link
    h.link_to name, object
  end

  def project_link
    h.link_to(project.name, project) if project
  end

  def gravatar_url(size = 80)
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{gravatar_id}?size=#{size}"
  end

  def gravatar_image(options = {})
    size = options.delete(:size)
    h.image_tag gravatar_url(size), options
  end

  def github_link(options = {})
    if github_connected?
      h.link_to "http://github.com/#{gh_nick}", title: gh_nick do
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

end
