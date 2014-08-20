class HipChat::DailyDigest
  attr_accessor :ending_projects, :kickoff_projects,
                :beginning_memberships, :ending_memberships

  TOMORROW = 0
  IN_A_WEEK = 6

  def initialize
    raise 'HipChat set to inactive in configuration' unless AppConfig.hipchat.active

    set_digest_content
  end

  def deliver
    send_hipchat_messages(:projects, :kickoff)
    send_hipchat_messages(:memberships, :beginning)
    send_hipchat_messages(:projects, :ending)
    send_hipchat_messages(:memberships, :ending)
  end

  private

  def set_digest_content
    set_in_bounds(:beginning_memberships, Membership.potential, :starts_at)
    set_in_bounds(:ending_memberships, Membership.active, :ends_at)
    set_in_bounds(:ending_projects, Project.ending_in_a_week, :end_at)
    set_in_bounds(:kickoff_projects, Project.potential, :kickoff)
  end

  def set_in_bounds(variable, objects, evaluator)
    results = objects.select do |object|
      if object.public_send(evaluator).present?
        [TOMORROW, IN_A_WEEK].include? \
          ((object.public_send(evaluator).to_time - Time.current.to_time) / 1.day).to_i
      end
    end
    instance_variable_set("@#{variable}", results)
  end

  def send_hipchat_messages(target, scope)
    targets = instance_variable_get("@#{scope}_#{target}")
    if targets.present?
      targets.each do |t|
        msg = HipChat::MessageBuilder.public_send("#{target.to_s.singularize}_#{scope}_message", t)
        HipChat::Notifier.new.send_notification(msg)
      end
    end
  end
end
