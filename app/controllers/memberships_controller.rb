class MembershipsController < ApplicationController

  include Shared::RespondsController

  respond_to :json, only: [:create, :update]

  expose(:membership, attributes: :membership_params)
  expose(:memberships)
  expose_decorated(:projects) { Project.by_name }
  expose_decorated(:roles) { Role.by_name }
  expose_decorated(:users) { current_user.admin? ? User.by_name : [current_user] }

  before_filter :authenticate_admin!, only: [:update, :destroy, :create, :edit], unless: -> { membership.user == current_user }
  before_action :set_users_gon, only: [:new, :create]

  def create
    if membership.save
      respond_to do |format|
        path = request.referer
        path = memberships_path if Rails.application.routes.recognize_path(request.referrer)[:action] == 'new'
        format.html { redirect_to path, notice: 'Membership created!' }
        format.json { render :show }
      end
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
      redirect_to request.referer, notice: 'Membership deleted!'
    else
      redirect_to request.referer, flash[:alert] = 'Something went wrong. Delete unsuccessful'
    end
  end

  protected

  def membership_params
    params.require(:membership).permit(:starts_at, :ends_at, :project_id, :user_id, :role_id, :billable)
  end

  private

  def set_users_gon
    gon.rabl template: 'app/views/memberships/users', as: 'users'
  end
end
