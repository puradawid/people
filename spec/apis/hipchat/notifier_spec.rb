require 'spec_helper'

describe HipChat::Notifier do
  subject { HipChat::Notifier.new }
  it { should respond_to(:send_notification).with(1).argument }
end

