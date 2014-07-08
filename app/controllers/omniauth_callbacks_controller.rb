class OmniauthCallbacksController <  ApplicationController
  skip_before_filter :authenticate_user!, only: :google_oauth2
  skip_before_filter :connect_github, only: :github
  skip_before_render :message_to_js
  before_filter :check_internal_user, only: :google_oauth2

  def google_oauth2
    user = User.create_from_google!(request.env['omniauth.auth'])
    sign_in(user)
    redirect_to root_path
  end

  def github
    github_nickname = request.env['omniauth.auth'][:info][:nickname]
    current_user.update_attributes(gh_nick: github_nickname)
    redirect_to root_path
  end

  private

  def check_internal_user
    if request.env['omniauth.auth']['extra']['raw_info']['hd'] != AppConfig.emails.internal
      redirect_to root_path, error: 'No internal user'
    end
  end
end
