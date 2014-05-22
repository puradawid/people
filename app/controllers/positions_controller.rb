class PositionsController < ApplicationController

  expose(:position, attributes: :position_params)
  expose(:positions)
  expose(:positions_decorated) { Position.by_user_name(PositionDecorator.decorate_collection(Position.all)) }
  expose_decorated(:users) { current_user.admin? ? User.by_name : [current_user] }
  expose_decorated(:roles) { Role.by_name }

  def new
    position.user = current_user
  end

  def create
    if position.save
      path = user_path(current_user)
      path = positions_path unless current_user == position.user
      respond_to do |format|
        format.html { redirect_to path, notice: I18n.t('positions.success.create') }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :new, alert: I18n.t('positions.error.create') }
        format.json { render json: { errors: position.errors }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if position.save
      respond_to do |format|
        format.html { redirect_to positions_path, notice: I18n.t('positions.success.update') }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :edit, alert: I18n.t('positions.error.update') }
        format.json { render json: { errors: position.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if position.destroy
      redirect_to request.referer, notice: I18n.t('positions.success.deleted')
    else
      redirect_to request.referer, alert: I18n.t('positions.error.delete')
    end
  end

  private

  def position_params
    params.require(:position).permit(:starts_at, :user_id, :role_id)
  end
end
