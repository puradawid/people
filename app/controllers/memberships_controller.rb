class MembershipsController < ApplicationController
  include Shared::RespondsController
  include ContextFreeRepos

  respond_to :json, only: [:create, :update]

  expose(:membership, attributes: :membership_params)
  expose_decorated(:memberships) { memberships_repository.all }
  expose_decorated(:projects) { projects_repository.all_by_name }
  expose_decorated(:roles) { roles_repository.all_by_name }
  expose_decorated(:users) { current_user.admin? ? users_repository.all_by_name : [current_user] }

  before_filter :authenticate_admin!, only: [:index, :update, :destroy, :create, :edit], unless: -> { membership.user == current_user }
  before_action :set_users_gon, only: [:new, :create]

  def index; end

  def create
    if membership.save
      respond_on_success
    else
      respond_on_failure membership.errors
    end
  end

  def update
    if membership.save
      respond_on_success user_path(membership.user)
    else
      respond_on_failure membership.errors
    end
  end

  def destroy
    if membership.destroy
      respond_on_success request.referer
    else
      respond_on_failure membership.errors
    end
  end

  protected

  def membership_params
    params.require(:membership)
      .permit(:starts_at, :ends_at, :project_id, :user_id, :role_id, :billable, :booked)
  end

  private

  def set_users_gon
    gon.rabl template: 'app/views/memberships/users', as: 'users'
  end
end
