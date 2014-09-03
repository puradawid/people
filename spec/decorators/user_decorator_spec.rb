require 'spec_helper'

describe UserDecorator do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, team_join_time: 6.days.ago) }
  let(:user_without_team) { create(:user) }

  describe '#days_in_current_team' do
    context 'user without team' do
      subject { user_without_team.decorate }
      it { expect(subject.days_in_current_team).to eq(0) }
    end

    context 'user with team' do
      subject { user.decorate }
      it { expect(subject.days_in_current_team).to eq(6) }
    end
  end
end
