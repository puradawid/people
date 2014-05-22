require 'spec_helper'

describe Api::V1::ApiController do
  render_views

  controller(Api::V1::ApiController) do
    def index; render text: "nothing"; end
  end

  describe "#authenticate_api" do

    context "with valid token" do
      it "should not call render" do
        get :index, token: AppConfig.api_token
        expect(response.body).to eq("nothing")
      end
    end

    context "with invalid token" do
      it "should call render with 403 status" do
        get :index, token: "whatever"
        expect(response.status).to eq(403)
      end
    end
  end
end
