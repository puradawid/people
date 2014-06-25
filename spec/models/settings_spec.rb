require 'spec_helper'

describe Settings do

  context 'without any Settings instance initialized yet' do

    it 'sets the notifications_email' do
      expect(Settings.notifications_email).to eq nil
      Settings.instance.notifications_email = 'foobar@example.com'
      expect(Settings.notifications_email).to eq 'foobar@example.com'
    end
  end
end

