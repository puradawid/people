require 'spec_helper'

describe 'Available users page', js: true do
  let(:senior_role) { create(:admin_role) }
  let(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:angular_ability) { create(:ability, name: 'AngularJS') }
  let!(:dev_with_no_skillz) { create(:user, :available) }
  let!(:angular_dev) { create(:user, :available, abilities: [angular_ability]) }
  let!(:another_dev) { create(:user, :available, available_since: 10.days.from_now) }

  before { sign_in(user) }

  describe 'filters' do
    it 'allows to filter by abilities' do
      expect(page).to have_content angular_dev.first_name
      expect(page).to have_content dev_with_no_skillz.first_name

      select_option('abilities', 'AngularJS')
      expect(page).to have_content angular_dev.first_name
      expect(page).to_not have_content dev_with_no_skillz.first_name
    end

    it 'allows to filter by availability time' do
      select_option('availability_time', 'From now')

      expect(page).to have_content angular_dev.first_name
      expect(page).to have_content dev_with_no_skillz.first_name
      expect(page).not_to have_content another_dev.first_name
    end

    it 'allows to display all users after selecting from now' do
      expect(page).to have_content another_dev.first_name

      select_option('availability_time', 'From now')

      expect(page).to have_content angular_dev.first_name
      expect(page).to have_content dev_with_no_skillz.first_name
      expect(page).not_to have_content another_dev.first_name

      select_option('availability_time', 'All')

      expect(page).to have_content another_dev.first_name
    end
  end

  describe 'table with users' do
    it 'displays users' do
      expect(page).to have_content user.first_name
    end

    it 'displays now if available_since is today' do
      expect(page).to have_content 'Now'
    end
  end
end
