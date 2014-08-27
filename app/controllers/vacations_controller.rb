class VacationsController < ApplicationController
  include Shared::RespondsController

  expose(:users) { User.all.decorate }
  expose_decorated(:user)
  expose(:vacations) { Vacation.all }
  expose(:vacation) { user.vacation }

  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  def index
  end

  def new
    user.build_vacation
  end

  def create
    vacation = user.build_vacation(vacation_params)
    if vacation.save
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  def update
    if user.vacation.update(vacation_params)
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  def destroy
    if vacation.destroy
      respond_on_success vacations_path
    else
      respond_on_failure vacation.errors
    end
  end

  private

  def vacation_params
    params.require(:vacation).permit(:starts_at, :ends_at, :user_id)
  end
end
