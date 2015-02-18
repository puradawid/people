require 'spec_helper'

describe 'Available users page', js: true do
  let(:senior_role) { create(:admin_role) }
  let(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:angular_ability) { create(:ability, name: 'AngularJS') }
  let!(:dev_with_no_skillz) { create(:user, :available) }
  let!(:angular_dev) { create(:user, :available, abilities: [angular_ability]) }

  before { sign_in(user) }

  describe 'filters' do
    it 'allows to filter by abilities' do
      expect(page).to have_content angular_dev.first_name
      expect(page).to have_content dev_with_no_skillz.first_name

      select_option('abilities', 'AngularJS')
      expect(page).to have_content angular_dev.first_name
      expect(page).to_not have_content dev_with_no_skillz.first_name
    end
  end

  describe 'table with users' do
    it 'displays users' do
      expect(page).to have_content user.first_name
    end
  end
end
