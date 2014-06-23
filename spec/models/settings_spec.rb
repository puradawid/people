require 'spec_helper'

describe Settings do

  it '#notifications_email' do
    Settings.instance.notifications_email = 'foobar@example.com'
    expect(Settings.notifications_email).to eq 'foobar@example.com'
  end
end

