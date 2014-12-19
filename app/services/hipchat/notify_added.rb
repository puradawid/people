module HipChat
  class NotifyAdded < Notify
    attr_accessor :membership

    def initialize(membership)
      self.membership = membership
    end

    def call!
      if AppConfig.hipchat.active && membership.active?
        msg = HipChat::MessageBuilder.membership_added_message(membership)
        hipchat_notify(msg)
      end
    end
  end
end
