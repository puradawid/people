class LocationsRepository
  def all
    @all ||= Location.all
  end
end
