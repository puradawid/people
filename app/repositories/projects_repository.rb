class ProjectsRepository
  def all
    Project.all
  end

  def with_notes
    all.includes(:notes)
  end

  def active
    all.where(archived: false)
  end

  def active_sorted
    active.sort_by { |project| project.name.downcase }
  end
end
