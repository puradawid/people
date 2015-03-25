class AvailableUsersRepository
  def all
    User.where(available: true)
      .where(archived: false)
      .where(:primary_role.in => technical_roles)
  end

  private

  def technical_roles
    Role.where(technical: true).pluck(:id)
  end
end
