require 'spec_helper'

describe Trello::ProjectEndChecker do
  include_context 'trello'

  let!(:user) do
    create(:user, first_name: 'Other', last_name: 'Developer')
  end
  let!(:project) { create(:project) }
  let!(:membership) do
    create :membership,
           project: project,
           user: user,
           ends_at: nil
  end

  context 'user card with removed label' do
    it 'adds end date for the membership' do
      expect do
        subject.run!
      end.to change{ membership.reload.ends_at }.from(nil).to Date.yesterday
    end
  end
end
