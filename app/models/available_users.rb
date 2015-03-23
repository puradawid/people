class AvailableUsers
  def all
    User.where(available: true)
  end
end
