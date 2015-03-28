class RolesRepository
  def all
    @all ||= Role.all
  end

  def all_by_name
    all.by_name
  end

  def admin_role
    @admin_role ||= AdminRole.first_or_create
  end
end
