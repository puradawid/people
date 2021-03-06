class PositionsController < ApplicationController
  include ContextFreeRepos
  include Shared::RespondsController

  expose(:position, attributes: :position_params)
  expose_decorated(:users) do
    current_user.admin? ? users_repository.all_by_name : [current_user]
  end
  expose_decorated(:roles) { roles_repository.all_by_name }

  before_filter :authenticate_admin!, except: [:new, :create]

  def new
    position.user = current_user
    position.user = params[:user] if params[:user]
  end

  def create
    if position.save
      respond_on_success user_path(position.user)
    else
      respond_on_failure position.errors
    end
  end

  def update
    if position.save
      respond_on_success user_path(position.user)
    else
      respond_on_failure position.errors
    end
  end

  def destroy
    if position.destroy
      redirect_to request.referer, notice: I18n.t('positions.success', type: 'delete')
    else
      redirect_to request.referer, alert: I18n.t('positions.error',  type: 'delete')
    end
  end

  private

  def position_params
    params.require(:position).permit(:starts_at, :user_id, :role_id)
  end
end
