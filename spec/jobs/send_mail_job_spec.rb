require 'spec_helper'

describe SendMailJob do
  let(:mailer){ SendMailJob.new }

  describe "#perform" do
    it "delivers an email" do
      expect{ mailer.async.perform(UserMailer, :notify_operations, 'an email') }
      .to change{ UserMailer.deliveries.size }.by(1)
    end
  end
end
