class AvailableUsersController < ApplicationController
  expose(:users) { fetch_available_users }
  expose(:roles) { Role.all }
  expose(:abilities) { Ability.all }

  def index
    gon.users = Rabl.render(users, 'available_users/index', view_path: 'app/views', format: :hash)
    gon.roles = roles
    gon.abilities = abilities
  end

  private

  def fetch_available_users
    User
      .includes(:roles, :admin_role, :location, :contract_type, :memberships, :abilities)
      .technical.active.available.by_last_name.decorate
  end
end
