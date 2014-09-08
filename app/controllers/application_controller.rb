class ApplicationController < ActionController::Base
  include BeforeRender

  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_filter :connect_github
  before_filter :set_gon_data
  #before_filter :check_expire_token

  before_render :message_to_js

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  def current_user
    @decorated_cu ||= super.decorate if super.present?
  end

  def current_user?
    user == current_user
  end

  def connect_github
    if signed_in? && !current_user.github_connected?
      redirect_to github_connect_path
    end
  end

  def check_expire_token
    if signed_in? && current_user.oauth_expires_at.nil? || (current_user.oauth_expires_at+1.hour < Time.now)

    end
  end

  private

  def authenticate_admin!
    redirect_to root_url, alert: "Permission denied! You have no rights to do this."  unless current_user.admin?
  end

  def set_gon_data
    return unless current_user
    gon.rabl template: "app/views/layouts/base.rabl", as: "current_user"
  end

  def message_to_js
    @flashMessage = { notice: [] , alert: [] }
    flash.each do |name, msg|
      @flashMessage[name] << msg
    end
    gon.rabl template: "app/views/layouts/flash.rabl", as: "flash"
    flash.clear
  end
end
