class SettingsController < ApplicationController
  before_filter :authenticate_admin!

  def update
    return render :edit unless Settings.update_attributes(allowed_params)
    redirect_to settings_path
  end

  def edit
  end

  private

  def allowed_params
    params.require(:settings).permit(:notifications_email)
  end
end

