class ProjectsRepository
  def all
    # FIXME: we should have a 2nd level of eager-loading here: memberships: :role
    # but it's not available in Mongo
    @all ||= Project.all.includes(:memberships, :notes).to_a
  end

  def get(id)
    all.find { |p| p.id == id }
  end

  def with_notes
    all
  end

  def active
    all.select { |p| !p.archived }
  end

  def active_sorted
    active.sort_by { |project| project.name.downcase }
  end
end
