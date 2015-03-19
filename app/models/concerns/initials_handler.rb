module InitialsHandler
  extend ActiveSupport::Concern

  included do
    before_save :set_initials
  end

  private

  def set_initials
    camel_case = name.underscore.split('_')
    splitted = camel_case.count > 1 ? camel_case : name.split
    self.initials = splitted[0..1].map { |w| w[0] }.join.upcase
  end
end
