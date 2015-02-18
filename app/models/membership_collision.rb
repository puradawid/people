class MembershipCollision
  attr_accessor :membership, :collisions

  def initialize(membership)
    @membership = membership
    @collisions = find_collisions
  end

  def call!
    return if junior_staying_in_current_project?
    return unless collisions.any?

    membership.errors.add(:project, 'user is not available at given time for this project')

    self
  end

  private

  def junior_staying_in_current_project?
    junior_dev? && booking? && collides_only_with_selected_project?
  end

  def junior_dev?
    membership.user.primary_role.try(:name) == 'junior'
  end

  def booking?
    membership.booked
  end

  def collides_only_with_selected_project?
    collisions.reject { |m| m.project == membership.project }.count == 0
  end

  def find_collisions
    if membership.ends_at.present?
      memberships.or(
        { :starts_at.lte => membership.ends_at, :ends_at.gte => membership.starts_at },
        { :starts_at.lte => membership.ends_at, :ends_at => nil }
      )
    else
      memberships.or({ ends_at: nil }, { :ends_at.gte => membership.starts_at })
    end
  end

  def memberships
    Membership
      .with_user(membership.user)
      .not_in(:_id => [membership.id])
      .where(project_id: membership.project.try(:id))
  end
end
