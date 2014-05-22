class DashboardController < ApplicationController
  expose(:projects) { Project.by_name }
  expose(:roles) { Role.all }
  expose(:users) { User.all.decorate }
  expose(:memberships) { Membership.unfinished.decorate }

  def index
    gon.rabl template: 'app/views/dashboard/users', as: 'users'
    gon.rabl template: 'app/views/dashboard/memberships', as: 'memberships'
    gon.rabl template: 'app/views/dashboard/roles', as: 'roles'
    gon.rabl template: 'app/views/dashboard/projects', as: 'projects'
    gon.currentTime = Time.now
  end
end
