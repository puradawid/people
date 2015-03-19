module Membership::HipchatNotifications
  extend ActiveSupport::Concern

  included do
    if AppConfig.hipchat.active
      after_create :notify_added
      after_update :notify_updated
      before_destroy :notify_removed
    end
  end

  def notify_added
    return unless active?
    msg = HipChat::MessageBuilder.membership_added_message(self)
    hipchat_notify(msg)
  end

  def notify_removed
    return unless active?
    msg = HipChat::MessageBuilder.membership_removed_message(self)
    hipchat_notify(msg)
  end

  def notify_updated
    return unless persisted? && active?
    msg = HipChat::MessageBuilder.membership_updated_message(self, changes)
    hipchat_notify(msg)
  end

  def hipchat_notify(msg)
    HipChat::Notifier.new.send_notification(msg)
  end
end
