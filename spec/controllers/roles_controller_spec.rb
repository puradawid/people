require 'spec_helper'

describe RolesController do
  before(:each) do
    admin = create(:admin_role)
    sign_in create(:user, admin_role_id: admin.id)
  end

  describe '#index' do
    render_views

    before do
      create(:role, name: 'junior')
      create(:role, name: 'developer')
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'exposes roles' do
      get :index
      expect(controller.roles.count).to be 2
    end

    it 'displays roles on view' do
      get :index
      expect(response.body).to match(/junior/)
      expect(response.body).to match(/developer/)
    end
  end

  describe '#show' do
    subject { create(:role, name: 'role1') }
    before { get :show, id: subject }

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'exposes role' do
      expect(controller.role).to eq subject
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      subject { attributes_for(:role, name: 'role2') }

      it 'creates a new role' do
        expect { post :create, role: subject }.to change(Role, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      subject { attributes_for(:role_invalid) }

      it 'does not save' do
        expect { post :create, role: subject, format: :json }.to_not change(Role, :count)
      end
    end
  end

  describe '#update' do
    let!(:role) { create(:role, name: 'senior4') }

    it 'exposes role' do
      put :update, id: role, role: role.attributes
      expect(controller.role).to eq role
    end

    context 'valid attributes' do
      it "changes role's attributes" do
        put :update, id: role, role: attributes_for(:role, name: 'p2m')
        role.reload
        expect(role.name).to eq 'p2m'
      end
    end

    context 'invalid attributes' do
      it "does not change role's attributes" do
        put :update, id: role, role: attributes_for(:role, name: nil), format: :json
        role.reload
        expect(role.name).to eq 'senior4'
      end
    end
  end
end
