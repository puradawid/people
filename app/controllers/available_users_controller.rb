class AvailableUsersController < ApplicationController

  expose(:roles) { Role.technical.decorate }

  def index; end

end
