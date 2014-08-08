require 'render_anywhere'

class HipChat::MessageBuilder
  extend RenderAnywhere

  def self.membership_added_message(membership)
    hipchat_render(
      'hipchat/memberships/added',
      { membership: membership.decorate }
    ).to_str
  end

  def self.membership_removed_message(membership)
    hipchat_render(
      'hipchat/memberships/removed',
      { membership: membership.decorate }
    ).to_str
  end

  def self.membership_updated_message(membership, changes)
    hipchat_render(
      'hipchat/memberships/updated',
      {
        membership: membership.decorate,
        changes: changes.except('updated_at')
      }
    ).to_str
  end

  private

  def self.hipchat_render(template_path, local_variables = {})
    render template: template_path,
      layout: false,
      xray: false,
      locals: local_variables
  end
end

