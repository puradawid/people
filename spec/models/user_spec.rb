require 'spec_helper'

describe User do
  subject { create(:user) }

  it { should have_one :vacation }
  it { should have_many :memberships }
  it { should have_many :notes }
  it { should have_many :positions }
  it { should belong_to :role }
  it { should belong_to :contract_type }
  it { should belong_to :location }
  it { should belong_to :team }
  it { should belong_to :leader_team }
  it { should have_and_belong_to_many :abilities }

  context 'validation' do
    it { should be_valid }

    describe 'employment hours' do

      context 'with employment greater than 0 and less than 200' do
        before { subject.employment = 160 }
        it { should be_valid }
      end

      context 'with employment greater than 200' do
        before { subject.employment = 250 }
        it { should_not be_valid }
      end

    end

    describe 'phone' do

      context 'with length less or equal than 16' do
        before { subject.phone = '123412341234' }
        it { should be_valid }
      end

      context 'with length greater than 16' do
        before { subject.phone = '12341234444412345' }
        it { should_not be_valid }
      end

      context "with '-'" do
        before { subject.phone = '111-222-333' }
        it { should be_valid }
      end

      context 'with letters' do
        before { subject.phone = '123412a' }
        it { should_not be_valid }
      end

      context 'with spaces' do
        before { subject.phone = '111 222 333' }
        it { should be_valid }
      end

      context 'with brackets' do
        before { subject.phone = '+48 111 222 333' }
        it { should be_valid }
      end

      context "with more spaces ot '-' next to each other" do
        before { subject.phone = '11--111  1' }
        it { should_not be_valid }
      end
    end

  end

  describe '#current_projects' do
    let!(:project) { create(:project, name: 'google') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    def time(year, month, day)
      Time.new(year, month, day)
    end

    it "returns projects list to include 'google' project" do
      create(:membership, starts_at: time(2013, 11, 1), ends_at: time(2014, 1, 1), user: subject, project: project)
      expect(subject.current_projects.first[:project]).to eq project
    end

    it 'returns no projects' do
      create(:membership, starts_at: time(2012, 1, 1), ends_at: time(2013, 11, 30), user: subject)
      expect(subject.current_projects).to be_empty
    end

    it 'returns projects array to include 2 projects' do
      create(:membership, starts_at: time(2011, 1, 1), ends_at: time(2012, 1, 1), user: subject, role: create(:role, name: 'pm1'))
      create(:membership, starts_at: time(2012, 1, 1), ends_at: time(2014, 1, 1), user: subject, role: create(:role, name: 'pm2'))
      create(:membership_without_ends_at, starts_at: time(2013, 1, 1), user: subject, role: create(:role, name: 'pm3'))
      expect(subject.current_projects.count).to eq 2
    end
  end

  describe '#end_memberships' do
    let!(:user_to_archive) { create(:user, archived: false) }
    let!(:project) { create(:project, name: 'google') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    def time(year, month, day)
      Time.new(year, month, day).end_of_day - 1.second
    end

    context 'when user gets archived' do
      before do
        create(:membership, starts_at: time(2012, 1, 1),
               ends_at: nil, user: user_to_archive, project: project)
      end

      it 'returns current project' do
        expect(user_to_archive.memberships.first.ends_at).to be_nil
      end

      it 'ends his memberships' do
        user_to_archive.update(archived: true)
        expect(user_to_archive.memberships.first.ends_at).to_not be_nil
      end
    end
  end

  describe '#has_project' do
    let!(:project) { create(:project, name: 'google') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    def time(year, month, day)
      Time.new(year, month, day)
    end

    context 'when user has current project' do
      before do
        create(:membership, starts_at: time(2012, 1, 1), ends_at: nil, user: subject)
      end

      it 'returns true' do
        expect(subject.has_current_projects?).to be_true
      end
    end

    context "when user hasn't current project" do
      it 'returns false' do
        expect(subject.has_current_projects?).to be_false
      end
    end

  end

  describe '#next_projects' do
    let!(:project_current) { create(:project, name: 'google') }
    let!(:project_next) { create(:project, name: 'facebook') }

    before { Timecop.freeze(Time.local(2013, 12, 1)) }
    after { Timecop.return }

    def time(year, month, day)
      Time.new(year, month, day)
    end

    context 'when user has unstarted membership' do
      before do
        create(:membership, starts_at: time(2012, 1, 1), ends_at: nil,
                            user: subject, project: project_current)
        create(:membership, starts_at: time(2013, 12, 15), ends_at: nil,
                            user: subject, project: project_next)
      end

      it 'returns next project' do
        expect(subject.next_projects.first[:project].name).to eq project_next.name
      end
    end
  end

  describe '#potential_projects' do
    let!(:project_potential) { create(:project, potential: true) }

    context 'when user belongs to potential project' do
      before do
        create(:membership, starts_at: 2.days.ago, ends_at: nil,
                            user: subject, project: project_potential)
      end

      it 'returns potential project' do
        expect(subject.potential_projects.first[:project]).to eq project_potential
      end
    end
  end

  describe '#get_from_api' do

    context 'using id' do
      let(:params) { { 'id' => subject.id } }

      it 'finds the user' do
        expect(User.get_from_api(params)).to eq subject
      end
    end

    context 'using email' do
      let(:params) { { 'email' => subject.email } }

      it 'finds the user' do
        expect(User.get_from_api(params)).to eq subject
      end
    end
  end

  describe '#get users with UoP contract' do

    context 'when user have UoP contracts' do
      let(:contract_uop) { create(:contract_type, name: 'UoP') }
      let(:senior_role) { create(:role, name: 'senior', technical: true) }
      let!(:user_with_uop) do
        create(:user, role_id: senior_role.id,
                      contract_type_id: contract_uop.id)
      end
      let!(:user_without_uop) { create(:user, role_id: senior_role.id) }

      it 'return user with UoP contract' do
        expect(User.contract_users('UoP').to_a).to include user_with_uop
      end
      it 'will not return user without UoP contract' do
        expect(User.contract_users('UoP').to_a).to_not include user_without_uop
      end
    end
  end

  describe '#days_in_current_team' do

    let(:team1) { double('Team', id: 'team1_id', name: 'team1') }
    let(:team2) { double('Team', id: 'team2_id', name: 'team2') }
    let(:user) { create(:user, team_id: team1.id, team_join_time: Time.now) }

    context 'when user.team_id is updated' do
      it 'user.team_join_time updates as well' do
        expect { user.update(team_id: team2.id) }.to change { user.team_join_time }
      end
    end
  end

  describe "#booked_memberships" do
    let!(:project_current) { create(:project, name: "google", potential: true) }
    let!(:project_next) { create(:project, name: "facebook", potential: false) }
    let(:first_memb) do
      create(:membership,
        starts_at: Time.now, ends_at: nil, user: subject, project: project_current)
    end
    let(:sec_memb) do
      create(:membership,
        starts_at: 1.month.from_now, ends_at: nil, user: subject, project: project_next)
    end

    context "when booked membership attribute ends_at is nil" do
      before do
        first_memb.update_attribute(:booked, true)
        sec_memb.update_attribute(:booked, true)
      end

      it "returns an empty array" do
        expect(subject.booked_memberships).to eq([])
      end
    end

    context "when booked membership attribute ends_at is set " do
      before do
        first_memb.update_attribute(:booked, true)
        sec_memb.update_attribute(:booked, true)
        first_memb.update_attribute(:ends_at, 2.weeks.from_now)
        sec_memb.update_attribute(:ends_at, 3.months.from_now)
      end

      it "returns memberships in the right order" do
        expect(subject.booked_memberships).to eq([first_memb, sec_memb])
      end
    end
  end
end
