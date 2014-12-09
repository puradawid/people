class AvailableUsersController < ApplicationController

  expose_decorated(:users) { available_users }
  expose_decorated(:roles) { Role.technical }

  def index; end

  private

  def available_users
    number_of = (params[:months] || 0).to_i
    @roles = Role.technical.to_a
    User.active.available.roles(@roles)
  end
end
