require 'render_anywhere'

class HipChat::MessageBuilder
  extend RenderAnywhere

  def self.membership_added_message(membership)
    hipchat_render(
      'hipchat/memberships/added',
      { membership: membership.decorate }
    )
  end

  def self.membership_beginning_message(membership)
    hipchat_render(
      'hipchat/memberships/beginning',
      { membership: membership.decorate }
    )
  end

  def self.membership_ending_message(membership)
    hipchat_render(
      'hipchat/memberships/ending',
      { membership: membership.decorate }
    )
  end

  def self.membership_removed_message(membership)
    hipchat_render(
      'hipchat/memberships/removed',
      { membership: membership.decorate }
    )
  end

  def self.membership_updated_message(membership, changes)
    hipchat_render(
      'hipchat/memberships/updated',
      {
        membership: membership.decorate,
        changes: changes.except('updated_at')
      }
    )
  end

  def self.project_ending_message(project)
    hipchat_render(
      'hipchat/projects/ending',
      { project: project.decorate }
    )
  end

  def self.project_kickoff_message(project)
    hipchat_render(
      'hipchat/projects/kickoff',
      { project: project.decorate }
    )
  end

  private

  def self.hipchat_render(template_path, local_variables = {})
    render(
      template: template_path,
      layout: false,
      locals: local_variables
    ).to_str
  end
end

