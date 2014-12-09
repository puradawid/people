require 'spec_helper'

describe ApplicationHelper do
  let!(:user) { create(:user, first_name: 'Joe', last_name: 'Doe', phone: '23544', email: 'ex@ample.com') }

  describe '#profile_link' do
    it 'returns link to user profile' do
      user.decorate
      expect(helper).to receive(:link_to).with('Doe Joe', user_path(user))
      helper.profile_link(user.decorate)
    end
  end
end
