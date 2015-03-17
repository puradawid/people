require 'spec_helper'

describe DashboardController do
  before(:each) do
    sign_in create(:user, first_name: 'Marian')
  end

  describe '#index' do
    let!(:old_membership) { create(:membership, ends_at: 1.day.ago) }
    let!(:new_membership) { create(:membership, ends_at: 1.day.from_now) }
    let!(:archived_membership) { create(:membership, ends_at: 1.day.from_now, project_archived: true) }

    before { get :index }

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    describe 'exposing unfinished memberships' do
      it 'exposes unfinished memberships' do
        expect(controller.memberships).to include(new_membership)
      end

      it "doesn't expose finished and archived memebrships" do
        expect(controller.memberships).not_to include([old_membership, archived_membership])
      end
    end
  end
end
