class RolesRepository
  def all
    @all ||= Role.all.to_a
  end

  def admin_role
    @admin_role ||= AdminRole.first_or_create
  end
end
