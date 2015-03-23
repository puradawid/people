class MembershipsRepository
  def all
    Membership.includes(:project, :user, :role).all
  end

  def active_ongoing
    Membership.unfinished.not_archived
  end
end
