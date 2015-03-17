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

    context 'when user has not started a project' do
      let!(:future_dev) { create(:user) }
      let!(:future_membership) { create(:membership, user: future_dev, starts_at: 1.week.from_now) }

      it 'shows the user' do
        full_name = "#{future_dev.last_name} #{future_dev.first_name}"
        visit '/dashboard'
        select_option('users', full_name)

        if page.has_css?('.invisible')
          within '.invisible' do
            expect(page).not_to have_text(full_name)
          end
        end

        within '#projects-users' do
          expect(page).to have_text(full_name)
        end
      end
    end
  end

  describe 'projects filter' do
    it 'shows all projects when empty string provided' do
      within '#projects-users' do
        expect(page).to have_text('zztop')
        expect(page).to have_text('test')
      end
    end

    it 'shows only matched projects when project name provided' do
      select_option 'projects', 'zztop'

      within '#projects-users' do
        expect(page).to have_text('zztop')
        expect(page).not_to have_text('test')
      end
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

  describe 'User sorts filtered list' do
    let!(:junior_dev) { create(:user, primary_role: create(:junior_role, technical: true)) }
    let!(:junior_membership) { create(:membership, user: junior_dev, role: junior_dev.primary_role) }

    it 'does not disable the filter' do
      visit '/'
      select_option('roles', 'junior')
      find('div.up[data-sort="role_name"]').trigger 'click'

      expect(page).to have_text junior_dev.last_name
      expect(page).not_to have_text dev_user.last_name
    end
  end
end
