class PositionsController < ApplicationController

  expose(:position, attributes: :position_params)
  expose(:positions)
  expose(:positions_decorated) { PositionDecorator.decorate_collection Position.by_user_name_and_date }
  expose_decorated(:users) { current_user.admin? ? User.by_name : [current_user] }
  expose_decorated(:roles) { Role.by_name }

  def new
    position.user = current_user
    position.user = params[:user] if params[:user]
  end

  def create
    if position.save
      respond_on_success 'create'
    else
      respond_on_failure 'create'
    end
  end

  def update
    if position.save
      respond_on_success 'update'
    else
      respond_on_failure 'update'
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

  def respond_on_success(action_type)
    respond_to do |format|
      format.html { redirect_to user_path(position.user), notice: I18n.t('positions.success', type: action_type) }
      format.json { render :show }
    end
  end

  def respond_on_failure(action_type)
    respond_to do |format|
      format.html { render :new, alert: I18n.t('positions.error', type: action_type) }
      format.json { render json: { errors: position.errors }, status: :unprocessable_entity }
    end
  end

  def position_params
    params.require(:position).permit(:starts_at, :user_id, :role_id)
  end
end
