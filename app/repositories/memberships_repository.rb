class MembershipsRepository
  def all
    Membership.includes(:project, :user, :role).all
  end

  def active_ongoing
    Membership.unfinished.not_archived
  end

  def upcoming_changes(days)
    Membership.includes(:project).any_of(
      Membership.between(ends_at: Time.now..days.days.from_now).selector,
      Membership.between(starts_at: Time.now..days.days.from_now).selector
    )
  end
end
