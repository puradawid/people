class AvailableUsersController < ApplicationController
  include ContextFreeRepos

  expose(:users) do
    AvailableUserDecorator.decorate_collection(available_users_repository.all)
  end
  expose(:roles) { roles_repository.all }
  expose(:abilities) { abilities_repository.all }

  def index
    gon.users = Rabl.render(users, 'available_users/index', view_path: 'app/views', format: :hash)
    gon.roles = roles
    gon.abilities = abilities
  end
end
