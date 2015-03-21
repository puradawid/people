class UserRolesRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def all
    # CHECKQUERY:
    @all ||= user.roles.to_a
  end
end
