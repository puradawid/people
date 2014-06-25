require 'spec_helper'

describe Settings do

  context 'without any Settings instace initialized yet' do
    it 'returns unset notifications_email' do
      expect(Settings.notifications_email).to eq nil
    end

    it 'sets the notifications_email' do
      Settings.instance.notifications_email = 'foobar@example.com'
      expect(Settings.notifications_email).to eq 'foobar@example.com'
    end
  end
end

