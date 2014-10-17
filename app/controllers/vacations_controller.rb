class VacationsController < ApplicationController
  include Shared::RespondsController
  include Calendar

  expose_decorated(:user)
  expose(:vacations) { Vacation.all }
  expose(:vacation) { user.vacation }

  require_feature :vacations

  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  def index
    @users = User.by_vacation_date
  end

  def new
    user.build_vacation
  end

  def create
    vacation = user.build_vacation(vacation_params)
    if vacation.save
      export_vacation(user)
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  def update
    if vacation.update(vacation_params)
      update_vacation(user) if vacation.eventid.present?
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  def destroy
    if vacation.destroy
      delete_vacation(user) if vacation.eventid.present?
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  def import
    import_vacation(current_user)
    redirect_to '/vacations'
  end

  private

  def vacation_params
    params.require(:vacation).permit(:starts_at, :ends_at, :user_id)
  end
end
