class DashboardController < ApplicationController
  expose(:projects) { Project.by_name }
  expose(:roles) { Role.all }
  expose_decorated(:users) { User.includes(:memberships).all }
  expose_decorated(:developers, decorator: UserDecorator) { find_developers }
  expose_decorated(:project_managers, decorator: UserDecorator) { find_pms }
  expose_decorated(:quality_assurances, decorator: UserDecorator) { find_qas }
  expose_decorated(:memberships) { Membership.unfinished }

  def index
    gon.rabl template: 'app/views/dashboard/users', as: 'users'
    gon.rabl template: 'app/views/dashboard/memberships', as: 'memberships'
    gon.rabl template: 'app/views/dashboard/roles', as: 'roles'
    gon.rabl template: 'app/views/dashboard/projects', as: 'projects'
    gon.rabl template: 'app/views/dashboard/developers', as: 'developers'
    gon.rabl template: 'app/views/dashboard/project_managers', as: 'project_managers'
    gon.rabl template: 'app/views/dashboard/quality_assurance', as: 'quality_assurance'
    gon.currentTime = Time.now

    if params[:cookie]
      cookies[:note_id] = params[:cookie]
    else
      cookies.delete(:note_id)
    end
  end

  private

  def find_developers
    UserSearch.new(developer: true).results
  end

  def find_pms
    UserSearch.new(pm: true).results
  end

  def find_qas
    UserSearch.new(qa: true).results
  end
end
