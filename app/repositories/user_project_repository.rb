class UserProjectRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
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
end
