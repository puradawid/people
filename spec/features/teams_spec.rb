require 'spec_helper'
describe "team view" do
  let(:senior_role) { create(:role_admin) }
  let(:non_dev_role) { create(:role) }
  let(:user) { create(:user, role_id: senior_role.id) }
  let!(:dev_user) { create(:user, first_name: 'Developer Daisy', role_id: senior_role.id) }
  let!(:non_dev_user) { create(:user, first_name: 'Nondev Nigel', role_id: non_dev_role.id) }
  let!(:archived_user) { create(:user, first_name: 'Archived Arthur', archived: true) }
  let!(:team) { create(:team) }
  let!(:team_user) { create(:user, first_name: 'Developer Dave', role_id: senior_role.id, team_id: team.id) }

  before(:each) do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    visit '/teams'
  end

  describe ".show-users button", js: true do
    before(:each) do
      find('.show-users').click
    end

      it "doesn't show archived users" do
        expect(page).not_to have_content archived_user.first_name
      end

      it "shows devs only" do
        expect(page).to have_content dev_user.first_name
        expect(page).not_to have_content non_dev_user.first_name
      end
  end

  describe ".new-team-add", js: true do
    before(:each) do
      find('.new-team-add').click
    end

    it "shows new team form" do
      expect(page).to have_content "Add team"
    end

    it "adds new team" do
      find('.js-new-team-form .form-control.name').set('teamX')
      expect{ find('a.new-team-submit').click }.to change(Team, :count).from(1).to(2)
    end
  end

  describe ".js-add-member", js: true do

      it "shows selectize field" do
        find('span.js-add-member').click
        expect(page).to have_css('.js-team-member-new')
      end

      it "adds new member to the team" do
          find('span.js-add-member').click
          find('.selectize-input input').set('Developer Daisy')
          find(:css, '.person .name').click
          expect(page).to have_content('Developer Daisy')
      end
  end

  describe ".js-promote-leader", js: true do
    it 'promotes member to leader' do
        find('.js-promote-leader').click
        expect(page).to have_xpath("//td[@id='leader-region']/td")
    end
  end

  describe ".js-exclude-member", js: true do
    it 'removes member from the team' do
      find('.js-exclude-member').click
      expect(page).not_to have_xpath("//td[@id='members-region']//td")
    end
  end
end
