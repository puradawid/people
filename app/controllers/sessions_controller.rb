class SessionsController < Devise::SessionsController
  skip_before_filter :connect_github

  def create
    redirect_to root_path
  end
end
