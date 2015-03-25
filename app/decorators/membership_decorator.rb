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
    elsif booked?
      'booked'
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

  def project_name
    return '' unless project.present?
    project.name
  end

  def role_name
    role.name
  end

  def ends_at_date
    if ends_at.present?
      ends_at.to_date
    else
      h.content_tag("span", "unexpired", class: "label label-default")
    end
  end
end
