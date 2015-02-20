require 'spec_helper'

describe 'Other » Projects' do
  let(:senior_role) { create(:admin_role) }
  let!(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:active_project) { create(:project) }
  let!(:potential_project) { create(:project, :potential) }
  let!(:archived_project) { create(:project, :archived) }

  before do
    sign_in(user)
    visit '/projects' # Other » Projects… only for admins
  end

  describe 'search' do
    it 'allows to find project by query' do
      fill_in 'search', with: active_project.name
      click_button 'search'

      expect(page).to have_content active_project.name
      expect(page).to_not have_content potential_project.name
    end
  end

  describe 'table' do
    it 'has remove button for potential projects' do
      expect(page.find('tr', text: potential_project.name)).to have_content 'Delete'
    end

    it 'does not have remove button for active / archived projects' do
      expect(page.find('tr', text: active_project.name)).to_not have_content 'Delete'
    end
  end
end
