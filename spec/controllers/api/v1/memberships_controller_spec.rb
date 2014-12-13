require 'spec_helper'

describe Api::V1::MembershipsController do
  render_views
  before { controller.class.skip_before_filter :authenticate_api! }
  let!(:user) { create(:user) }
  let!(:role) { create(:role) }
  let!(:project) { create(:project) }
  let(:membership) { create(:membership, user_id: user._id, project_id: project._id, role_id: role._id) }

  let!(:any_membership) { create(:membership) }
  let(:membership_attrs) do
    attributes_for(:membership).merge(user_id: user._id, project_id: project._id, role_id: role._id)
  end
  let(:rabl_attributes) { [:id, :starts_at, :ends_at, :user_id, :project_id] }

  describe 'GET #index' do
    before do
      get :index, format: :json
    end

    it 'returns 200 code' do
      expect(response.status).to eq(200)
    end

    it 'returns all memberships' do
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(Membership.count)
    end
  end

  describe 'GET #show' do
    before do
      get :show, format: :json, id: membership.id
    end

    it 'returns 200 code' do
      expect(response.status).to eq(200)
    end

    it 'returns correct hash keys' do
      json_resposne = response.body
      expect(json_response.keys).to eq(rabl_attributes.map(&:to_s))
    end
  end

  describe 'POST #create' do
    it 'returns 201 code' do
      post :create, format: :json, membership: membership_attrs
      expect(response.status).to eq(201)
    end

    it 'increments the amount of memberships' do
      expect { post :create, format: :json, membership: membership_attrs }
        .to change(Membership, :count).by(1)
    end
  end

  describe 'PUT #update' do
    before do
      membership.billable = 1
      put :update, id: membership.id, format: :json, membership: membership.attributes
    end

    it 'returns 204 code' do
      expect(response.status).to eq(204)
    end

    it 'updates the attribute in params' do
      expect(Membership.find(membership.id).billable).to be_true
    end
  end

  describe 'DELETE #destroy' do
    it 'returns 204 code' do
      delete :destroy, id: membership.id, format: :json
      expect(response.status).to eq(204)
    end

    it 'decrements the amount of memberships' do
      expect { delete :destroy, id: any_membership, format: :json }
        .to change(Membership, :count).by(-1)
    end
  end
end
