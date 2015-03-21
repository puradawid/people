require 'spec_helper'

describe 'profile', js: true do
  let(:user) { create(:junior_dev) }

  before do
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    create(:junior_role)
    create(:pm_role)
    create(:role_billable)
    visit user_path(user.id)
  end

  describe 'setting role' do
  end

  describe 'adding roles' do
    it 'adds role to user' do
      expect(page).to have_select('js-user-primary', options: ['no role'])
      select('junior', from: 'js-user-roles')
      select('pm', from: 'js-user-roles')
      within('form.edit_user') do
        first('input[type=submit]').click
      end
      expect(page).to have_select('js-user-primary', options: ['no role', 'junior', 'pm'])
    end
  end
end
