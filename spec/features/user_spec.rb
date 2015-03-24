require 'spec_helper'

describe 'Profile page', js: true do
  subject { page }
  let(:user) { create(:user, first_name: 'Jack', last_name: 'Sparrow') }
  before {
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
  }

  context 'is not displayed by users without access' do
    let(:other) { create(:user) }
    before { visit user_path(other.id) }

    xit { expect(page).to have_content('Permission denied!') }
  end

  context 'has billable role' do
    before do
      user.primary_role.update_attribute(:billable, true)
      visit user_path(user.id)
    end

    it { expect(page.find('[name="membership[billable]"]').value).to eq "1" }
  end
end
