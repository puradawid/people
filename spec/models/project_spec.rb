describe Project do
  subject { build(:project) }

  it { should have_many :memberships }
  it { should be_valid }
  it { should validate_presence_of :name }
  it { should validate_presence_of :slug }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_uniqueness_of(:slug).case_insensitive }

  describe "pm" do
    let(:actual_membership) { build(:membership, starts_at: 1.week.ago, ends_at: 1.week.from_now) }
    let(:old_membership) { build(:membership, starts_at: 2.weeks.ago, ends_at: 1.week.ago) }
    let(:future_membership) { build(:membership, starts_at: 1.week.from_now, ends_at: 2.weeks.from_now) }

    before do
      allow(Membership).to receive(:with_role).and_return([actual_membership, old_membership, future_membership])
    end

    its(:pm) { should eq(actual_membership.user) }
    its(:pm) { should_not eq(old_membership.user) }
    its(:pm) { should_not eq(future_membership.user) }
  end

  describe "nonpotential_switch" do
    let(:date) { Date.new(2014, 04, 20) }
    let(:date2) { Date.new(2013, 10, 10) }
    let(:project) { build(:project, created_at: date2) }
    let(:project_potential) { build(:project, potential: true, created_at: date2) }

    context "when project has history" do
      before do
        Timecop.freeze(date) do
          project_potential.update_attributes(potential: false)
          project_potential.reload
        end
      end

      it "returns last switch to non potential" do
        expect(project_potential.nonpotential_switch.to_date).to eq(date)
      end
    end

    context "when project has no history" do
      it "returns created_at attribute" do
        expect(project.nonpotential_switch.to_date).to eq(date2)
      end
    end
  end

  describe "three_months_old" do
    let(:date) { Date.new(2014, 02, 01) }
    let!(:project) { create(:project, created_at: date - 3.months) }
    let!(:project2) { create(:project, created_at: date - 3.months - 1.day) }
    let!(:project_potential) { create(:project, potential: true, created_at: date) }

    context "when project has history" do
      before do
        Timecop.freeze(date - 3.months) do
          project_potential.update_attributes(potential: false)
          project_potential.reload
        end
      end

      it "returns project" do
        Timecop.freeze(date) do
          expect(Project.three_months_old).to include(project_potential)
        end
      end
    end

    context "when project has no history" do
      before { Project.any_instance.stub(:history_tracks) { [HistoryTracker.new] } }

      it "returns project" do
        Timecop.freeze(date) do
          expect(Project.three_months_old).to include(project)
        end
      end

      it "does not return project" do
        expect(Project.three_months_old).not_to include(project2)
      end
    end
  end

  describe 'kickoff_tomorrow' do
    before do
      2.times { |t| create(:project, kickoff: Time.current + t.hours, potential: true) }

      create(:project, kickoff: Time.current + 12.hours, potential: false)
      create(:project, kickoff: Time.current + 2.days, potential: true)
    end

    it 'returns potential projects scheduled for kickoff in next 24 hours' do
      expect(Project.kickoff_tomorrow.count).to eq 2
    end
  end

  describe 'validations' do
    context 'with an empty slug' do
      it 'does not pass' do
        FactoryGirl.build(:project, slug: '').should_not be_valid
      end

      it 'pass if project is potential' do
        FactoryGirl.build(:project, potential: true, slug: '').should be_valid
      end
    end
  end
end
