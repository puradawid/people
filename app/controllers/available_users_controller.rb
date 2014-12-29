class AvailableUsersController < ApplicationController

  expose_decorated(:users) { available_users }
  expose_decorated(:roles) { Role.technical }

  def index; end

  private

  def available_users
    @roles = Role.technical.to_a
    User.active.available.roles(@roles).decorate.sort_by(&:availability)
  end
end
