class UserProjectRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def active_with_memberships
    memberships_by_project.select{ |project, _membership| !project.archived? }
      .sort_by { |_project, memberships| memberships.first.starts_at }
  end

  def archived_with_memberships
    memberships_by_project.select{ |project, _membership| project.archived? }
      .sort_by { |_project, memberships| memberships.first.starts_at }
  end

  def potential
    user_membership_repository.potential
    self
  end

  def next
    user_membership_repository.next
    self
  end

  def current
    user_membership_repository.current
    self
  end

  def items
    memberships = user_membership_repository.items
    ProjectSearch.new(memberships: memberships).results
  end

  private

  def user_membership_repository
    @user_membership_repository ||= UserMembershipRepository.new(user)
  end

  def memberships_by_project
    # CHECKQUERY: we use membership.role in view
    user_membership_repository.items.by_starts_at.group_by(&:project_id).each_with_object({}) do
      |data, memo|
      memberships = data[1]
      # FIXME: use repo
      project = Project.find(data[0])
      memo[project] = memberships
    end
  end

end
