require 'spec_helper'

describe VacationCheckerJob do
  let(:checker) { VacationCheckerJob.new }
  let!(:vacation) { create(:vacation, eventid: 1, ends_at: Date.today-1.day) }
  before { AppConfig.stub(:calendar_id).and_return('1') }

  describe '#perform' do
    before do
      stub_request(:delete, "https://www.googleapis.com/calendar/v3/calendars/1/events/1").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer 123', 'Cache-Control'=>'no-store',
          'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(:status => 200, :body => "", :headers => {})
    end
    it 'deletes expired vacation' do
      expect{ checker.perform(vacation.id) }.to change(Vacation, :count).by(-1)
    end
  end
end
