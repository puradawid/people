class SessionsController < Devise::SessionsController
  skip_before_filter :connect_github
end
