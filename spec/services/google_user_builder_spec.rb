require 'spec_helper'

describe GoogleUserBuilder do
  let(:sample_data) {
    {
      uid: 'google123',
      info: {
        first_name: 'Jan',
        last_name: 'Kowalski',
        email: 'jan@kowalski.pl'
      },
      extra: { raw_info: { hd: 'example.com' }},
      credentials: {
        oauth_token: 123,
        refresh_token: 456,
        oauth_expires_at: Time.now+1.hour
      }
    }
  }

  subject { described_class.new(sample_data) }

  describe '#call!' do
    context 'when user already exists' do
      let!(:user) { create(:user, email: 'jan@kowalski.pl') }

      it 'do not creates new user' do
        expect { subject.call! }.to_not change { User.count }
      end

      it 'updates user' do
        expect { subject.call! }.to change { user.reload.uid }
      end
    end

    context 'when user does not exists' do
      it 'creates new user' do
        expect { subject.call! }.to change { User.count }
      end
    end
  end
end
