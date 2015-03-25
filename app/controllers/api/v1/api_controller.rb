module Api::V1
  class ApiController < ActionController::Base
    include ContextFreeRepos

    before_filter :authenticate_api!
    respond_to :json

    decent_configuration do
      strategy DecentExposure::StrongParametersStrategy
    end

    private

    def authenticate_api!
      render(nothing: true, status: 403) unless params[:token] == AppConfig.api_token
    end
  end
end
