class FeaturesController < Flip::FeaturesController
  before_filter :authenticate_admin!
end
