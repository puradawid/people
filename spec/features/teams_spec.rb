require 'spec_helper'

describe 'team view', js: true do
  let(:billable_role) { create(:role_billable) }
  let(:admin_role) { create(:admin_role) }
  let(:non_dev_role) { create(:role) }
  let(:dev_role) { create(:role) }
  let(:hidden_role) { create(:role, show_in_team: false)}
  let(:user) { create(:user, admin_role_id: admin_role.id) }
  let!(:dev_user) { create(:user, first_name: 'Developer Daisy', admin_role_id: admin_role.id, role_id: billable_role.id) }
  let!(:non_dev_user) { create(:user, first_name: 'Nondev Nigel', role_id: non_dev_role.id) }
  let!(:archived_user) { create(:user, first_name: 'Archived Arthur', archived: true) }
  let!(:no_role_user) { create(:user, first_name: 'Norole Nicola') }
  let!(:hidden_user) { create(:user, first_name: 'Hidden Amanda', role_id: hidden_role.id, team_id: team.id) }
  let!(:team) { create(:team) }
  let!(:team_user) { create(:user, first_name: 'Developer Dave', role_id: dev_role.id, team_id: team.id) }

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

    it 'shows all users, not only devs' do
      expect(page).to have_content dev_user.first_name
      expect(page).to have_content non_dev_user.first_name
      expect(page).not_to have_content no_role_user.first_name
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

  describe '.js-add-member' do
    it 'adds new member to the team' do
      find('.selectize-input input').set('Developer Daisy')
      find(:css, '.person .name').click
      expect(page).to have_content('Developer Daisy')
    end
  end

  describe '.js-promote-leader' do
    it 'promotes member to leader' do
      find('.js-promote-leader').click
      expect(page).to have_xpath('//ul[@id="leader-region"]/ul')
    end
  end

  describe '.js-exclude-member' do
    it 'removes member from the team' do
      find('.js-exclude-member').click
      expect(page).not_to have_xpath('//td[@id="members-region"]//td')
    end
  end

  describe '.js-edit-team' do
    before(:each) do
      find('.js-edit-team').click
    end

    it 'shows edit form' do
      expect(page).to have_content('edit name')
    end

    it 'updates team name' do
      find('.ui-dialog input.new-name').set('Relatively OK team')
      find('.edit-team-name button').click
      expect(page).to have_content('Relatively OK team')
    end
  end
end
