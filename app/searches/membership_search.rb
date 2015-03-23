1class MembershipSearch < Searchlight::Search
  search_on Membership.includes(:project, :user)

  searches :user, :archived, :booked, :ends_later_than, :with_end_date, :potential,
    :starts_earlier_than, :starts_later_than, :project_end_time

  def search_user
    search.where(user_id: user.id)
  end

  def search_archived
    search_for_project(archived: archived)
  end

  def search_potential
    search_for_project(potential: potential)
  end

  def search_project_end_time
    search_for_project(end_at: project_end_time)
  end

  def search_ends_later_than
    search.any_of({ :ends_at.gte => ends_later_than }, { ends_at: nil })
  end

  def search_starts_earlier_than
    search.where(:starts_at.lte => starts_earlier_than)
  end

  def search_starts_later_than
    search.where(:starts_at.gte => starts_later_than)
  end

  def search_booked
    search.where(booked: booked)
  end

  def search_with_end_date
    ends_at = with_end_date ? :ends_at.ne : :ends_at
    search.where(ends_at => nil)
  end

  private

  def search_for_project(params)
    project_ids = ProjectSearch.new(params).results.pluck(:_id)
    search.where(:project_id.in => project_ids)
  end
end
