require 'spec_helper'
describe Api::V1::ProjectsController do
  render_views
  before { controller.class.skip_before_filter :authenticate_api! }

  let!(:project) { create(:project) }
  let(:project_keys) { ['name'] }

  describe "GET #index" do

    before do
      get :index, format: :json
      @json_response = JSON.parse(response.body)
    end

    it "returns 200 code" do
      expect( response.status ).to eq 200
    end

    it "contains current_week fields" do
      expect(@json_response.first.keys).to eq(project_keys)
    end
  end
end
