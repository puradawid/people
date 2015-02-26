require "spec_helper"

describe "Users page", js: true do
  let(:user) { create(:user) }
  let!(:developer) { create(:user, first_name: 'Developer Daisy') }

  before(:each) do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    visit '/users'
  end

  it "shows user role" do
    expect(page).to have_content(developer.primary_role.name)
  end
end
