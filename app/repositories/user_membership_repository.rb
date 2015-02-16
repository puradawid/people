class UserMembershipRepository
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def all
    clear_search
  end

  %w(potential archived booked with_end_date).each do |m|
    define_method m do
      search(m.to_sym => true)
    end
    define_method ['not', m].join('_') do
      search(m.to_sym => false)
    end
  end

  def without_end_date
    not_with_end_date
  end

  def not_ended
    search(ends_later_than: Time.now)
  end

  def started
    search(starts_earlier_than: Time.now)
  end

  def not_started
    search(starts_later_than: Time.now)
  end

  def not_ended_project
    search(project_end_time: Time.now)
  end

  def current
    not_potential.not_archived.started.not_ended.not_ended_project
  end

  def currently_booked
    search(ends_later_than: Time.now).booked
  end

  def items
    search = MembershipSearch.new(search_params)
    clear_search
    search.results
  end

  def next
    not_started.not_ended.not_potential.not_booked.not_ended_project
  end

  private

  def search(params)
    @search_params = search_params.merge(params)
    self
  end

  def search_params
    @search_params ||= { user: user }
  end

  def clear_search
    @search_params = nil
  end
end
