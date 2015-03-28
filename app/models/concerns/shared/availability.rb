module Shared
  module Availability
    extend ActiveSupport::Concern

    included do
      after_save :check_user_availability
      after_destroy :check_user_availability
    end
  end
end
