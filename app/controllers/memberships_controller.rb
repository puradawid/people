class MembershipsController < ApplicationController

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
        format.html { redirect_to request.referer, notice: 'Membership created!' }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :new, alert: 'Something went wrong. Create unsuccessful' }
        format.json { render json: { errors: membership.errors }, status: 400 }
      end
    end
  end

  def update
    if membership.save
      respond_to do |format|
        format.html { redirect_to edit_membership_path, notice: 'Membership updated!' }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :edit, alert: 'Something went wrong. Update unsuccessful' }
        format.json { render json: { errors: membership.errors }, status: 400 }
      end
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
