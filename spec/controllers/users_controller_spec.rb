require 'spec_helper'

describe UsersController do
  render_views

  describe '#index' do
    before do
      sign_in create(:user, first_name: 'Marian')
      create(:user, first_name: 'Tomek')
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'exposes users' do
      get :index
      expect(controller.users.count).to be 2
    end

    it 'displays users on view' do
      get :index
      expect(response.body).to match(/Marian/)
      expect(response.body).to match(/Tomek/)
    end
  end

  describe '#show' do
    let(:user) { create(:user, first_name: 'Dean', last_name: 'Winchester') }
    before do
      sign_in user
      get :show, id: user
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'displays user name on view' do
      expect(response.body).to match(/Winchester Dean/)
    end
  end
end
