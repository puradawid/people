require 'spec_helper'

describe VacationsController do
  before(:each) do
    AppConfig.stub(:calendar_id).and_return('1')
    admin = create(:admin_role)
    sign_in create(:user, oauth_token: '132', admin_role_id: admin.id)
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
    let!(:user) { create(:user, first_name: 'John', last_name: 'Doe', email: 'johndoe@example.com') }
    before do
      stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/1/events").
        with(:body => "{\"summary\":\"John Doe - vacation\",\"start\":{\"date\":\"2014-09-02\"},\"end\":{\"date\":\"2014-09-11\"}}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
            'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "result.txt")),
          :headers => { 'Content-Type' => 'application/json' })
    end

    context 'with valid attributes' do
      subject{ attributes_for(:vacation, starts_at: "2014-09-02", ends_at: "2014-09-10") }

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
    let!(:vacation) { create(:vacation, starts_at: "2014-09-02", ends_at: "2014-09-09") }
    before do
      stub_request(:get, "https://www.googleapis.com/calendar/v3/calendars/1/events/").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'User-Agent'=>'calendar/1.0 google-api-ruby-client/0.6.4 Linux/3.2.0-4-amd64'}).
         to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "result.txt")),
          :headers => { 'Content-Type' => 'application/json' })

      stub_request(:put, "https://www.googleapis.com/calendar/v3/calendars/1/events/").
        with(:body => "{\"id\":1,\"start\":{\"date\":\"2014-09-02\"},\"end\":{\"date\":\"2014-09-11\"}}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
            'Content-Type'=>'application/json',
            'User-Agent'=>'calendar/1.0 google-api-ruby-client/0.6.4 Linux/3.2.0-4-amd64'}).
        to_return(:status => 200, :body => "", :headers => {})
    end

    context 'with valid attributes' do
      it 'changes attributes of vacation' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(
          :vacation, ends_at: "2014-09-10")
        vacation.reload
        expect(vacation.ends_at).to eq(("2014-09-10").to_date)

      end
    end

    context 'with invalid attributes' do
      it 'does not change attributes of vacation' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(:vacation, ends_at: nil)
        vacation.reload
        expect(vacation.ends_at).to eq(("2014-09-09").to_date)
      end

      it 're-renders the edit method' do
        put :update, user_id: vacation.user.id, vacation: attributes_for(:vacation, ends_at: nil)
        expect(response).to render_template :edit
      end
    end
  end

  describe '#delete' do
    let!(:vacation) { create(:vacation) }
    before do
      stub_request(:delete, "https://www.googleapis.com/calendar/v3/calendars/1/events/").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'User-Agent'=>'calendar/1.0 google-api-ruby-client/0.6.4 Linux/3.2.0-4-amd64'}).
        to_return(:status => 200, :body => "", :headers => {})
    end

    it 'deletes the vacation' do
      expect{
        delete :destroy, user_id: vacation.user.id
      }.to change(Vacation, :count).by(-1)
    end
  end
end
