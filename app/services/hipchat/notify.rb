module HipChat
  class Notify
    def hipchat_notify(msg)
      HipChat::Notifier.new.send_notification(msg)
    end
  end
end
