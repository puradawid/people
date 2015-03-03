require 'spec_helper'

describe 'Dashboard filters', js: true do
  let(:senior_role) { create(:admin_role) }
  let(:role) { create(:role_billable) }
  let(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:dev_user) { create(:user, last_name: 'Developer', first_name: 'Daisy', admin_role_id: senior_role.id) }
  let!(:membership) { create(:membership, user: dev_user, project: project_test, role: role) }
  let!(:project_zztop) { create(:project, name: 'zztop') }
  let!(:project_test) { create(:project, name: 'test') }

  before(:each) do
    sign_in(user)
    visit '/dashboard'
  end

  describe 'users filter' do
    it 'returns only matched projects when user name provided' do
      select_option('users', 'Developer Daisy')
      expect(page).to have_text('test')
      expect(page).to_not have_text('zztop')
    end

    it 'returns all projects when no selectize provided' do
      expect(page).to have_text('zztop')
      expect(page).to have_text('test')
    end
  end

  describe 'abilities filter' do
    let(:rails) { create(:ability, name: 'Rails') }
    let(:ember) { create(:ability, name: 'Ember') }
    let!(:backend_developer)    { create(:user, abilities: [rails]) }
    let!(:frontend_developer)   { create(:user, abilities: [ember]) }
    let!(:full_stack_developer) { create(:user, abilities: [rails, ember]) }

    before { visit '/users' }

    it 'returns users with given ability' do
      select_option('abilities', 'Rails')

      expect(page).to have_text backend_developer.last_name
      expect(page).not_to have_text frontend_developer.last_name
    end

    context 'with multiple abilities' do
      it 'returns users with all abilities' do
        select_option('abilities', 'Rails')
        select_option('abilities', 'Ember')

        expect(page).to have_text full_stack_developer.last_name
        expect(page).not_to have_text backend_developer.last_name
        expect(page).not_to have_text frontend_developer.last_name
      end
    end
  end
end
