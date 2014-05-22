class MembershipDecorator < Draper::Decorator
  delegate_all
  decorates_association :user
  decorates_association :role

  def user_name
    user.present? ? user.name : '---'
  end

  def duration_in_words
    if terminated?
      h.distance_of_time_in_words(starts_at, ends_at)
    elsif started?
      'current'
    else
      'not started'
    end
  end

  def date_range
    range = "#{h.icon('calendar')} #{starts_at.to_date}"
    range << " ... #{ends_at.to_date}" if ends_at
    h.raw range
  end
end
