class RolesRepository
  def all
    Role.all
  end

  def get_admin
    AdminRole.first_or_create
  end
end
