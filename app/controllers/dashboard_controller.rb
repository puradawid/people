class DashboardController < ApplicationController
  expose(:projects) { Project.by_name }
  expose(:roles) { Role.all }
  expose(:users) { User.includes(:memberships).all.decorate }
  expose(:memberships) { Membership.unfinished.decorate }

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

  def developers
    User.all.decorate.select{ |u| u.role.present? && u.role.technical? }
  end

  def project_managers
    User.all.decorate.select{ |u| u.role.present? && ( u.role.name == 'pm' || u.role.name == 'junior pm' )}
  end

  def quality_assurance
    User.all.decorate.select{ |u| u.role.present? && ( u.role.name == 'qa' || u.role.name == 'junior qa' )}
  end
end
