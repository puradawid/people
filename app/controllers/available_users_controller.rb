class AvailableUsersController < ApplicationController

  expose(:users) { available_users.decorate }
  expose(:roles) { Role.technical.decorate }

  def index; end

  private

  def available_users
    @roles = Role.technical.to_a
    User.active.available.roles(@roles)
  end
end
