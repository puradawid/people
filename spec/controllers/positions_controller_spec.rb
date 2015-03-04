require 'spec_helper'

describe PositionsController do
  before(:each) do
    admin = create(:admin_role)
    sign_in create(:user, admin_role_id: admin.id)
  end

  describe '#new' do
    before { get :new }

    it 'responds success with HTTP status 200' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'exposes new position' do
      expect(controller.position.created_at).to be_nil
    end
  end

  describe '#create' do
    let(:role) { create(:role, name: 'junior1', technical: true) }
    let(:user) { create(:user, primary_role: role) }
    let!(:params) { attributes_for(:position, user_id: user._id, role_id: role._id) }

    context 'with valid attributes' do
      it 'creates a new position' do
        expect { post :create, position: params }.to change(Position, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) { params.except(:starts_at) }

      it 'does not save' do
        expect { post :create, position: invalid_params }.to_not change(Position, :count)
      end
    end
  end

  describe '#update' do
    let(:role) { create(:role, name: 'junior1', technical: true) }
    let(:user) { create(:user, primary_role: role) }
    let!(:position) { create(:position, user: user, role: role) }

    it 'exposes positions' do
      put :update, id: position, position: position.attributes
      expect(controller.position).to eq position
    end

    context 'valid attributes' do
      it 'changes position start date' do
        attributes = { starts_at: Date.new(2014, 05, 19) }
        put :update, id: position, position: attributes
        position.reload
        expect(position.starts_at.day).to eq 19
      end
    end

    context 'invalid attributes' do
      it 'does not change position attributes' do
        attributes = { starts_at: nil }
        put :update, id: position, position: attributes
        position.reload
        expect(position.starts_at.day).to_not be nil
      end
    end
  end

  describe '#destroy' do
    let(:intern_role) { create(:role, name: 'intern', technical: true) }
    let(:user) { create(:user, primary_role: intern_role) }
    let!(:position) { create(:position, user: user, role: intern_role) }

    it 'deletes the position' do
      @request.env['HTTP_REFERER'] = positions_path
      expect { delete :destroy, id: position }.to change(Position, :count).by(-1)
    end
  end
end
