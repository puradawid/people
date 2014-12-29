require 'spec_helper'
include Calendar

describe Calendar do
  let!(:user) do
    create(:user, first_name: 'John', last_name: 'Doe', email: 'johndoe@example.com',
   refresh_token: '456')
  end
  before do
    AppConfig.stub(:google_client_id).and_return('789')
    AppConfig.stub(:google_secret).and_return('a99')
    AppConfig.stub(:calendar_id).and_return('1')
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
end
