class RolesController < ApplicationController
  include ContextFreeRepos

  respond_to :json

  expose(:role, attributes: :role_params)
  expose(:roles) { roles_repository.all }

  before_filter :authenticate_admin!, only: [:index, :create, :update]

  def index
    gon.rabl as: 'roles'
  end

  def create
    if role.save
      render :role, status: :created
    else
      respond_with role
    end
  end

  def update
    if role.save
      render :role
    else
      respond_with role
    end
  end

  def sort
    RolesPriorityUpdater.new(params[:role]).call!
    render json: {}
  end

  private

  def role_params
    params.require(:role).permit(
      :name, :color, :billable, :technical, :show_in_team
      )
  end
end
