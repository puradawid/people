module HipChat
  class NotifyRemoved < Notify
    attr_accessor :membership

    def initialize(membership)
      self.membership = membership
    end

    def call!
      if AppConfig.hipchat.active && membership.active?
        msg = HipChat::MessageBuilder.membership_removed_message(self)
        hipchat_notify(msg)
      end
    end
  end
end
