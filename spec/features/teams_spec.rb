require 'spec_helper'

describe 'team view', js: true do
  let(:billable_role) { create(:role_billable) }
  let(:admin_role) { create(:admin_role) }
  let(:non_dev_role) { create(:role, name: 'junior qa') }
  let(:hidden_role) { create(:role, show_in_team: false)}
  let(:user) { create(:user, admin_role_id: admin_role.id) }
  let!(:dev_role) { create(:role, name: 'developer') }
  let!(:junior_role) { create(:role, name: 'junior', billable: false) }
  let!(:dev_user) { create(:user, first_name: 'Developer Daisy', admin_role_id: admin_role.id, primary_role: billable_role) }
  let!(:non_dev_user) { create(:user, first_name: 'Nondev Nigel', primary_role: non_dev_role) }
  let!(:archived_user) { create(:user, first_name: 'Archived Arthur', archived: true) }
  let!(:no_role_user) { create(:user, first_name: 'Norole Nicola') }
  let!(:hidden_user) { create(:user, first_name: 'Hidden Amanda', primary_role: hidden_role, team_id: team.id) }
  let!(:team) { create(:team) }
  let!(:team_user) { create(:user, first_name: 'Developer Dave', primary_role: billable_role, team_id: team.id) }
  let!(:junior_team_user) { create(:user, first_name: 'Junior Jake', primary_role: junior_role, team_id: team.id) }

  before(:each) do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    visit '/teams'
  end

  describe '.show-users button' do
    before(:each) do
      find('.show-users').click
    end

    it "doesn't show archived users" do
      expect(page).not_to have_content archived_user.first_name
    end

    it 'shows only users with roles chosen by admin' do
      expect(page).not_to have_content hidden_user.first_name
    end
  end

  describe '.new-team-add' do
    before(:each) do
      find('.new-team-add').click
    end

    it 'shows new team form' do
      expect(page).to have_content 'Add team'
    end

    it 'adds new team' do
      expect(Team.count).to eq 1
      find('.js-new-team-form .form-control.name').set('teamX')
      find('a.new-team-submit').click
      expect(page).to have_content 'teamX has been created'
      expect(Team.count).to eq 2
    end
  end

  describe '.js-promote-leader' do
    # Skip temporarily
    xit 'promotes member to leader' do
      first('.js-promote-leader').click
      expect(page).to have_xpath('//ul[@class="team-members filled" and @id="leader-region"]')
    end
  end

  describe '.js-edit-team' do
    before(:each) do
      find('.js-edit-team').click
    end

    it 'shows edit form' do
      expect(page).to have_content('New name')
    end

    it 'updates team name' do
      find('input.new-name').set('Relatively OK team')
      find('button.js-edit-team-submit').click
      expect(page).to have_content('Relatively OK team')
    end
  end

  describe '.devs-indicator' do
    it 'shows number of users in team' do
      indicator = first('.devs-indicator')
      devs_indicator = indicator.first('.devs').text
      jnrs_indicator = indicator.first('.jnrs').text
      expect(devs_indicator).to eq '1'
      expect(jnrs_indicator).to eq '1'
    end
  end
end
