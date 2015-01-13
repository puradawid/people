class AvailableUsersController < ApplicationController

  expose_decorated(:users) { available_users }
  expose_decorated(:roles) { Role.technical }

  expose(:roles) { Role.all }
  expose(:admin_role) { [AdminRole.first_or_create] }
  expose(:locations) { Location.all }
  expose(:projects) { Project.includes(:notes).all }
  expose(:abilities) { fetch_abilities }
  expose(:contractTypes) { ContractType.all }
  expose(:positions) { PositionDecorator.decorate_collection(user.positions) }

  def index
    gon.rabl as: 'users'
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.admin_role = admin_role
    gon.locations = locations
    gon.abilities = Ability.all
    gon.availability_time = availability_time
  end

  private

  def available_users
    @roles = Role.technical.to_a
    User.active.available.roles(@roles).decorate.sort_by(&:available_since)
  end

  def availability_time
    result = []
    result << { value: 0, text: "Now" }
    result << { value: 7, text: "1 week" }
    result << { value: 14, text: "2 weeks" }
    result << { value: 28, text: "4 weeks" }
    result << { value: 31, text: "1 month" }
    result << { value: 61, text: "2 months" }
    result << { value: 92, text: "3 months" }
    result
  end
end
