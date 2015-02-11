class BaseMailer < ActionMailer::Base
  default from: AppConfig.emails.from
end
