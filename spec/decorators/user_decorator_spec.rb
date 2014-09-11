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

  describe '#gravatar_url' do
    let(:user_md5) { Digest::MD5.hexdigest(subject.email.downcase) }
    it { expect(subject.gravatar_url).to eq "https://www.gravatar.com/avatar/#{user_md5}?size=80" }
  end

  describe '#gravatar_image' do
    it { expect(subject.gravatar_image(size: 80)).to include(subject.gravatar_url) }
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
end
