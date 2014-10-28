require 'spec_helper'

describe UserDecorator do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, team_join_time: 6.days.ago) }
  let(:user_without_team) { create(:user) }
  let(:project) { build_stubbed(:project) }
  subject { user.decorate }

  describe '#days_in_current_team' do
    context 'user without team' do
      subject { user_without_team.decorate }
      it { expect(subject.days_in_current_team).to eq(0) }
    end

    context 'user with team' do
      it { expect(subject.days_in_current_team).to eq(6) }
    end
  end

  describe '#as_row' do
    it { expect(subject.as_row).to eq [user.last_name, user.first_name, user.role, user.location] }
  end

  describe '#project_names' do
    before do
      subject.model.stub(:memberships) { [Membership.new(project: project)] }
    end

    it { expect(subject.project_names).to eq [project.name] }
  end

  describe '#link' do
    it { expect(subject.link).to eq h.link_to subject.name, user }
  end

  describe '#gravatar_image' do
    it { expect(subject.gravatar_image).to include(subject.gravatar_url.to_s) }
  end

  describe '#days_in_current_team' do
    before do
      user.team_join_time = 1.day.ago
    end
    it { expect(subject.days_in_current_team).to eq 1 }
  end

  describe '#github_link' do
    before do
      user.gh_nick = 'github_nick'
    end
    it { expect(subject.github_link).to include('github_nick') }
  end

  describe '#skype_link' do
    before do
      user.skype = 'skype_login'
    end
    it { expect(subject.skype_link).to include('skype_login') }
  end

  describe '#availability' do
    let!(:project) { create(:project, name: 'google') }
    let!(:membership) { create(:membership, starts_at: time(2013, 11, 1), ends_at: time(2014, 1, 1), user: subject, project: project) }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    def time(year, month, day)
      Time.new(year, month, day)
    end

    context 'with membership end date' do
      it 'returns membership end date' do
        expect(subject.availability.to_s).to eql membership.ends_at.to_s
      end
    end

    context 'without membership end date' do
      before { membership.update_attribute(:ends_at, nil) }

      it 'returns project end date' do
        expect(subject.availability.to_s).to eql project.end_at.to_s
      end

      context 'without project end date' do
        before { project.update_attribute(:end_at, nil) }

        it 'returns nil' do
          expect(subject.availability).to eql nil
        end
      end
    end
  end
end
