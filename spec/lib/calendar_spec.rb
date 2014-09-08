require 'spec_helper'
include Calendar

describe Calendar do
  let!(:user) { create(:user, first_name: "John", last_name: "Doe", email: "johndoe@example.com",
   refresh_token: '456') }
  before do
    AppConfig.stub(:google_client_id).and_return('789')
    AppConfig.stub(:google_secret).and_return('a99')
    AppConfig.stub(:calendar_id).and_return('1')
    AppConfig.stub(:calendar_summary_regex).and_return('vacation|urlop|wakacje')
  end

  describe '#initialize_client' do
    before { initialize_client(user) }

    it 'initialize new client' do
      expect(@client.authorization.access_token).to eq(user.oauth_token)
      expect(@client.authorization.refresh_token).to eq(user.refresh_token)
      expect(@client.authorization.client_id).to eq('789')
      expect(@client.authorization.client_secret).to eq('a99')
    end
  end

  describe '#export_vacation' do
    before do
      stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/1/events").
        with(:body => "{\"summary\":\"John Doe - vacation\",\"start\":{\"date\":\"2014-09-02\"},\"end\":{\"date\":\"2014-09-10\"}}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 123',
          'Cache-Control'=>'no-store', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "result.txt")),
          :headers => { 'Content-Type' => 'application/json' })
      user.build_vacation
      user.vacation.starts_at = "2014-09-02"
      user.vacation.ends_at = "2014-09-09"
      user.vacation.save
      export_vacation(user)
    end

    it 'exports new event to Google Calendar' do
      expect(user.vacation.eventid).to eq(1)
    end
  end

  describe '#update_vacation' do
    before do
      stub_request(:get, "https://www.googleapis.com/calendar/v3/calendars/1/events/1").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
          'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "result.txt")),
          :headers => { 'Content-Type' => 'application/json' })

      stub_request(:put, "https://www.googleapis.com/calendar/v3/calendars/1/events/1").
        with(:body => "{\"id\":1,\"start\":{\"date\":\"2014-09-02\"},\"end\":{\"date\":\"2014-09-10\"}}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
                'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => "", :headers => {})
      user.build_vacation
      user.vacation.starts_at = "2014-09-02"
      user.vacation.ends_at = "2014-09-09"
      user.vacation.eventid = 1
      user.vacation.save
      update_vacation(user)
    end

    it 'exports new event to Google Calendar' do
      expect(user.vacation.starts_at.to_date).to eq(("2014-09-02").to_date)
    end
  end

  describe '#import_vacation' do
    before do
      stub_request(:get, "https://www.googleapis.com/calendar/v3/calendars/1/events").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
          'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "import.txt")),
          :headers => { 'Content-Type' => 'application/json' })
    end

    context 'when user has vacation in database' do
      before do
        user.build_vacation
        user.vacation.starts_at = "2014-09-02"
        user.vacation.ends_at = "2014-09-09"
        user.vacation.eventid = 1
        user.vacation.save
        import_vacation(user)
      end

      it 'does not save imported event' do
        expect(user.vacation.starts_at).to eq(("2014-09-02").to_date)
        expect(user.vacation.ends_at).to eq(("2014-09-09").to_date)
      end
    end

    context 'when user does not have vacation in database yet' do
      context 'saves new imported event from Google Calendar' do
        before do
          import_vacation(user)
          user.reload
        end

        it 'if summary,dates and email are valid' do
          expect(user.vacation.nil?).to be_false
          expect(user.vacation.starts_at).to eq(("2015-03-02").to_date)
          expect(user.vacation.ends_at).to eq(("2015-03-08").to_date)
        end
      end

      context 'does not save imported event' do
        before do
          stub_request(:get, "https://www.googleapis.com/calendar/v3/calendars/1/events").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
              'Content-Type'=>'application/x-www-form-urlencoded'}).
            to_return(:status => 200, :body => File.read(File.join("spec", "support", "calendar", "invalid_import.txt")),
              :headers => { 'Content-Type' => 'application/json' })
          import_vacation(user)
          user.reload
        end

        it 'if summary, dates or email are not valid' do
          expect(user.vacation.nil?).to be_true
        end
      end
    end
  end
end

