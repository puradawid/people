class StrategiesController < Flip::StrategiesController
  before_filter :authenticate_admin!
end
