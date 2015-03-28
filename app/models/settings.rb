class Settings
  include Singleton
  include Mongoid::Document

  field :notifications_email, type: String

  validate :notifications_email, format: { with: Devise.email_regexp }

  class << self
    delegate :inspect, to: :instance

    def initialize
      @instance = first_or_create
    end

    def method_missing(method, *args)
      instance.public_send(method, *args) unless locked?
    end

    def instance
      lock do
        @instance ||= first_or_create
      end
    end

    private

    def lock
      @locked_instance = true
      result = yield
      @locked_instance = false
      result
    end

    def locked?
      @locked_instance
    end
  end
end
