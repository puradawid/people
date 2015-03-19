module HipChat
  class NotifyRemoved < Notify
    def call!
      return if !AppConfig.hipchat.active || !membership.active?
      msg = HipChat::MessageBuilder.membership_removed_message(membership)
      hipchat_notify(msg)
    end
  end
end
