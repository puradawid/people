require "spec_helper"

describe "User sign up", js: true do
  let(:senior_role) { create(:admin_role) }
  let(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:dev_user) { create(:user, first_name: 'Developer Daisy', admin_role_id: senior_role.id) }

  before(:each) do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    create(:project, name: "test")   
    create(:project, name: "zztop")
    visit '/projects'
  end

  it "return only matched projects when project name provided" do
    fill_in 'search', :with => 'test'
    click_button 'search'
    expect(page).to have_text('test')
    page.should have_no_content('zztop')
  end

  it "return all projects when empty string provided" do
    fill_in 'search', :with => ""
    click_button 'search'
    expect(page).to have_text('zztop')
    expect(page).to have_text('test')
  end
end

