class Sql::Settings < ActiveRecord::Base
  acts_as_singleton

  validate :notifications_email, format: { with: Devise.email_regexp }


  class << self
    delegate :inspect, to: :instance

    def method_missing method, *args
      instance.public_send(method, *args)
    end

  end

end
