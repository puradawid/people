require 'spec_helper'

describe 'profile', js: true do
  let(:user) { create(:plain_user) }
  let!(:junior_role) { create(:junior_role) }
  let!(:pm_role) { create(:pm_role) }
  let!(:role_billable) { create(:role_billable) }

  before do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
  end

  describe 'setting role' do
    before do
      user.roles = [junior_role, pm_role, role_billable]
      user.save
      visit user_path(user.id)
    end

    it 'set role to a user' do
      expect(page).to have_select('js-user-primary', selected: 'no role')
      select('junior', from: 'js-user-primary')
      within('form.edit_user') do
        first('input[type=submit]').click
      end
      expect(page).to have_select('js-user-primary', selected: 'junior')
    end
  end

  describe 'adding roles' do
    before do
      visit user_path(user.id)
    end

    xit 'adds role to user' do
      expect(page).to have_select('js-user-primary', options: ['no role'])
      select('junior', from: 'js-user-roles', visible: false)
      select('pm', from: 'js-user-roles', visible: false)
      within('form.edit_user') do
        first('input[type=submit]').click
      end
      expect(page).to have_select('js-user-primary', options: ['no role', 'junior', 'pm'])
    end
  end
end
