require 'spec_helper'

describe VacationsController do
  before(:each) do
    admin = create(:admin_role)
    sign_in create(:user, admin_role_id: admin.id)
  end

  describe '#index' do
    render_views
    let!(:vacation) { create(:vacation) }

    it 'responds successfully with an HTTP status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'exposes vacation' do
      get :index
      expect(controller.vacations.count).to be 1
    end

    it 'displays vacations on view' do
      get :index
      expect(response.body).to have_content(vacation.user.first_name)
      expect(response.body).to have_content(vacation.starts_at)
    end
  end

  describe '#create' do
    let!(:user) { create(:user) }

    context 'with valid attributes' do
      subject{ attributes_for(:vacation, starts_at: Time.now, ends_at: Time.now+7.days) }

      it 'creates a new vacation' do
        expect{
         post :create, user_id: user.id, vacation: subject
        }.to change(Vacation, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      subject { attributes_for(:vacation, starts_at: nil) }

      it 'does not save a new vacation' do
        expect{
         post :create, user_id: user.id, vacation: subject
        }.not_to change(Vacation, :count)
      end

      it 're-renders a new method' do
        post :create, user_id: user.id, vacation: subject
        expect(response).to render_template :new
      end
    end
  end

  describe '#update' do
    let!(:vacation) { create(:vacation, starts_at: Time.now, ends_at: Time.now+7.days) }

    context 'with valid attributes' do
      it 'changes attributes of vacation' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(
          :vacation, ends_at: Time.now+10.days)
        vacation.reload
        expect(vacation.ends_at).to eq((Time.now+10.days).to_date)
      end
    end

    context 'with invalid attributes' do
      it 'does not change attributes of vacation' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(:vacation, ends_at: nil)
        vacation.reload
        expect(vacation.ends_at).to eq((Time.now+7.days).to_date)
      end

      it 're-renders the edit method' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(:vacation, ends_at: nil)
        expect(response).to render_template :edit
      end
    end
  end

  describe '#delete' do
    let!(:vacation) { create(:vacation) }

    it 'deletes the vacation' do
      expect{
        delete :destroy, user_id: vacation.user.id
      }.to change(Vacation, :count).by(-1)
    end
  end
end
