class UserRepository

  def from_api(params)
    search(id_or_email: params)
  end

  def where(params)
    search(params).items
  end

  def active
    User
      .includes(:roles, :admin_role, :location, :contract_type, :memberships, :abilities)
      .active.by_last_name.decorate
  end

  def items
    search = UserSearch.new(search_params)
    clear_search
    search.results
  end

  def get(id)
    User.find id
  end

  def all_by_name
    User.by_name
  end

  def find_by(attrs)
    User.find_by attrs
  end

  private

  def api_request_params(params)
    params['id'].present? ? { id: params['id'] } : { email: params['email'] }
  end

  def search(params)
    @search_params = search_params.merge(params)
    self
  end

  def search_params
    @search_params ||= {}
  end

  def clear_search
    @search_params = nil
  end
end
