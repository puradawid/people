module HipChat
  class NotifyUpdated < Notify
    attr_accessor :membership

    def initialize(membership)
      self.membership = membership
    end

    def call!
      return if !AppConfig.hipchat.active || !membership.persisted? || !membership.active?
      msg = HipChat::MessageBuilder.membership_updated_message(membership, changes)
      hipchat_notify(msg)
    end
  end
end
