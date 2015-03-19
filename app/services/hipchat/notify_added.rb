module HipChat
  class NotifyAdded < Notify
    def call!
      return if !AppConfig.hipchat.active || !membership.active?
      msg = HipChat::MessageBuilder.membership_added_message(membership)
      hipchat_notify(msg)
    end
  end
end
