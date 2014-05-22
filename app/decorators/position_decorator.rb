class PositionDecorator < Draper::Decorator
  delegate_all
  decorates_association :user
  decorates_association :role
end
