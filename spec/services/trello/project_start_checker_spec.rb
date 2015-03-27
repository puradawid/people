require 'spec_helper'

describe Trello::ProjectStartChecker do
  include_context 'trello'

  let!(:user) { create(:user, first_name: 'John', last_name: 'Doe') }
  let!(:user_with_membership) do
    create(:user, first_name: 'Other', last_name: 'Developer')
  end
  let!(:project) { create(:project, name: 'secondproject') }
  let!(:membership) { create(:membership, project: project, user: user_with_membership) }

  context 'user card has a new label' do
    it 'creates a new membership for the user' do
      expect do
        subject.run!
      end.to change{ user.memberships.count }.by 1
    end

    it 'creates a membership that started yesterday' do
      subject.run!
      expect(user.memberships.first.starts_at).to eq Date.yesterday
    end

    it 'creates a membership with role set to current user position' do
      subject.run!
      expect(user.memberships.first.role).to eq user.primary_role
    end
  end

  context 'user card with existing label' do
    it 'does not create a new membership for the user' do
      expect{ subject.run! }.to_not change{ user_with_membership.memberships.count }.by 1
    end
  end
end
