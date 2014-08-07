class HipChat::Notifier
  attr_reader :client

  def initialize
    @client = HipChat::Client.new(AppConfig.hipchat.api_token)
  end

  def send_notification(message)
    @client[AppConfig.hipchat.room_name].send(
      AppConfig.hipchat.author_name,
      message,
      notify: AppConfig.hipchat.notify_users,
      color: AppConfig.hipchat.message_color
    )
  end
end

