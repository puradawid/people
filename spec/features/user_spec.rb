require 'spec_helper'

describe 'Profile page', js: true do
  subject { page }
  let(:user) { create(:user, first_name: 'Jack', last_name: 'Sparrow') }
  before { sign_in(user) }

  context 'is displayed only by owner' do
    before { visit user_path(user.id) }

    it { expect(page).to have_content('Sparrow Jack') }
  end

  context 'is not displayed by users without access' do
    let(:other) { create(:user) }
    before { visit user_path(other.id) }

    it { expect(page).to have_content('Permission denied!') }
  end
end
