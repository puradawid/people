module HipChat
  class Notify
    attr_accessor :membership

    def initialize(membership)
      self.membership = membership
    end

    def hipchat_notify(msg)
      HipChat::Notifier.new.send_notification(msg)
    end
  end
end
