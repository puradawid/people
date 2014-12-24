class SessionsController < Devise::SessionsController
  skip_before_filter :connect_github

  def create
    redirect_to available_users_path
  end
end
