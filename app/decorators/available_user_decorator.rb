class AvailableUserDecorator < UserDecorator
  def self.model_name
    ActiveModel::Name.new(User)
  end
end
