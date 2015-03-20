class UserRolesRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def all
    # CHECKQUERY:
    user.roles
  end
end
