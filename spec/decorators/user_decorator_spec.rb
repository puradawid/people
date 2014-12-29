require 'spec_helper'

describe UserDecorator do
  def time(year, month, day)
    Time.new(year, month, day)
  end

  let(:team) { create(:team) }
  let(:user) { create(:user, team: team, team_join_time: 6.days.ago) }
  let(:user_without_team) { create(:user) }
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
    let(:project) { build_stubbed(:project) }
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

    context 'with membership end date' do
      it 'returns membership end date' do
        expect(subject.availability.to_s).to eq membership.ends_at.to_s
      end
    end

    context 'without membership end date' do
      before { membership.update_attribute(:ends_at, nil) }

      it 'returns project end date' do
        expect(subject.availability.to_s).to eq project.end_at.to_s
      end

      context 'without project end date' do
        before { project.update_attribute(:end_at, nil) }

        it 'returns Time.now' do
          expect(subject.availability).to eq "since now"
        end
      end
    end
  end

  describe '#current_projects_with_memberships_json' do
    let!(:project) { create(:project, name: 'google') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    it "returns projects list to include 'google' project" do
      create(:membership, starts_at: time(2013, 11, 1), ends_at: time(2014, 1, 1), user: subject, project: project)
      expect(subject.current_projects_with_memberships_json.first[:project]).to eq project
    end

    it 'returns no projects' do
      create(:membership, starts_at: time(2012, 1, 1), ends_at: time(2013, 11, 30), user: subject, project: project)
      expect(subject.current_projects_with_memberships_json).to be_empty
    end

    it 'returns projects array to include 2 projects' do
      create(:membership, starts_at: time(2011, 1, 1), ends_at: time(2012, 1, 1), user: subject, role: create(:role, name: 'pm1'))
      create(:membership, starts_at: time(2012, 1, 1), ends_at: time(2014, 1, 1), user: subject, role: create(:role, name: 'pm2'))
      create(:membership_without_ends_at, starts_at: time(2013, 1, 1), user: subject, role: create(:role, name: 'pm3'))
      expect(subject.current_projects_with_memberships_json.count).to eq 2
    end
  end

  describe '#potential_projects_json' do
    let!(:project_potential) { create(:project, potential: true) }

    context 'when user belongs to potential project' do
      before do
        create(:membership, starts_at: 2.days.ago, ends_at: nil,
                            user: subject, project: project_potential)
      end

      it 'returns potential project' do
        expect(subject.potential_projects_json.first[:project]).to eq project_potential
      end
    end

    context 'when user used to belong to potential project' do
      before do
        create(:membership, starts_at: 10.days.ago, ends_at: 5.days.ago,
                            user: subject, project: project_potential)
      end

      it "returns no potential project" do
        expect(subject.potential_projects_json).to be_empty
      end
    end
  end

  describe '#next_projects_json' do
    let!(:project_current) { create(:project, name: 'google') }
    let!(:project_next) { create(:project, name: 'facebook') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    context 'when user has unstarted membership' do
      before do
        create(:membership, starts_at: time(2012, 1, 1), ends_at: nil,
                            user: subject, project: project_current)
        create(:membership, starts_at: time(2013, 12, 15), ends_at: nil,
                            user: subject, project: project_next)
      end

      it 'returns next project' do
        expect(subject.next_projects_json.first[:project].name).to eq project_next.name
      end
    end
  end
end
