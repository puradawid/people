class UserRepository

  def from_api(params)
    search(id_or_email: params)
  end

  def items
    search = UserSearch.new(search_params)
    clear_search
    search.results
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
