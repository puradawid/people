class UserPositionsRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def all
    user.positions
  end
end
