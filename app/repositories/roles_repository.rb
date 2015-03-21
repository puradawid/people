class RolesRepository
  def all
    Role.all
  end

  def admin_role
    AdminRole.first_or_create
  end
end
