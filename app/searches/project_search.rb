class ProjectSearch < Searchlight::Search
  search_on Project.all

  searches :memberships, :potential, :archived, :end_at

  def search_potential
    Project.where(potential: potential)
  end

  def search_archived
    Project.where(archived: archived)
  end

  def search_memberships
    Project.where(:_id.in => memberships.map(&:project_id))
  end

  def search_end_at
    Project.or({ :end_at.gte => end_at }, { end_at: nil })
  end

end
