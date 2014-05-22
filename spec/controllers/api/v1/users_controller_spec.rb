require 'spec_helper'
describe Api::V1::UsersController do
  render_views
  before { controller.class.skip_before_filter :authenticate_api! }

  let!(:user) { create(:user) }
  let(:user_keys) { ["id", "first_name", "last_name", "email", "contract_type", "archived", "abilities", "role", "memberships"] }

  describe "GET #index" do

    before do
      get :index, format: :json
      @json_response = JSON.parse(response.body)
    end

    it "returns 200 code" do
      expect( response.status ).to eq 200
    end

    it "contains current_week fields" do
      expect(@json_response.first.keys).to eq(user_keys)
    end
  end

  shared_examples_for "GET #show" do |attribute|
    describe "using #{attribute}" do
      before do
        execute_request
        @json_response = JSON.parse(response.body)
      end

      it "returns 200 code" do
        expect( response.status ).to eq 200
      end

      it "contains current_week fields" do
        expect(@json_response.keys).to eq(user_keys)
      end
    end
  end

  it_should_behave_like "GET #show", :id do
    let!(:execute_request) { get :show, id: user.id, format: :json }
  end
  it_should_behave_like "GET #show", :email do
    let!(:execute_request) { get :show, id: 1, email: user.email, format: :json }
  end
end
