class AvailableUsers
  def all
    User.where(available: true)
      .where(:primary_role.in => technical_roles)
  end

  private

  def technical_roles
    Role.where(technical: true).pluck(:id)
  end
end
