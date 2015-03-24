class AvailableUsersController < ApplicationController
  expose(:users) { AvailableUsers.new.all.decorate }
  expose(:roles) { Role.all }
  expose(:abilities) { Ability.all }

  def index
    gon.users = Rabl.render(users, 'available_users/index', view_path: 'app/views', format: :hash)
    gon.roles = roles
    gon.abilities = abilities
  end
end
