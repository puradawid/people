class UserMailer < BaseMailer
  def notify_operations(user)
    @user = user
    to = [AppConfig.emails.pm]
    mail(to: to, subject: "New user in the application.", user: @user)
  end
end
