require 'spec_helper'

describe Project do
  subject { build(:project) }

  it { should have_many :memberships }
  it { should be_valid }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_uniqueness_of(:slug) }
  it { should validate_format_of(:slug).
       to_allow('1ettersandnumber5').
       to_allow('').
       to_allow(nil).
       not_to_allow('ANYTHING-else07') }

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

  describe 'starting_tomorrow' do
    before do
      2.times { |t| create(:project, kickoff: Time.current + t.hours, potential: true) }

      create(:project, kickoff: Time.current + 12.hours, potential: false)
      create(:project, kickoff: Time.current + 2.days, potential: true)
    end

    it 'returns potential projects scheduled for kickoff in next 24 hours' do
      expect(Project.starting_tomorrow.count).to eq 2
    end
  end

  describe ".ending_in" do
    let(:days) { 30 }
    subject { described_class.ending_in(days).to_a.flatten }

    it "returns projects ending soon" do
      project = create :project, end_at: 1.week.from_now
      expect(subject).to include project
    end
  end

  describe ".starting_in" do
    let(:days) { 30 }
    subject { described_class.starting_in(days).to_a.flatten }

    it "returns projects starting soon" do
      project = create :project, kickoff: 1.week.from_now
      expect(subject).to include project
    end
  end

  describe ".ending_or_starting_in" do
    let(:days) { 30 }
    subject { described_class.ending_or_starting_in(days).to_a.flatten }

    it "returns projects ending or starting soon" do
      project1 = create :project, kickoff: 1.week.from_now
      project2 = create :project, end_at: 1.week.from_now
      project_not_included = create :project, kickoff: 1.year.from_now,
                                              end_at: 2.years.from_now
      expect(subject).to include project1, project2
      expect(subject).not_to include project_not_included
    end
  end

  describe '#upcoming_changes' do
    let(:days) { 30 }
    let(:user) { create(:user) }
    subject { described_class.upcoming_changes(days).to_a.flatten }

    it "returns projects with upcoming changes" do
      project1 = create :project, kickoff: 2.weeks.from_now
      project2 = create :project, end_at: 2.weeks.from_now
      # not included directly but included through membership
      project_through_membership = create :project, kickoff: 7.months.from_now,
                                                    end_at: 10.months.from_now
      create :membership, starts_at: 4.days.from_now,
                          project: project_through_membership, user: user
      expect(subject).to include project1, project2, project_through_membership
    end
  end

  describe "#set_initials" do
    let(:project_camel_case) { create(:project, name: 'BolshoeSpasibo') }
    let(:project) { create(:project, name: 'Blyuz') }
    let(:project_multiword) { create(:project, name: 'Bolshoe Spasibo Harosho') }

    context "camel case name" do
      it "sets initials of a project" do
        expect(project_camel_case.initials).to eq 'BS'
      end
    end

    context "1 word name" do
      it "sets initials of a project" do
        expect(project.initials).to eq 'B'
      end
    end

    context "multiword name with spaces" do
      it "sets initials of a project" do
        expect(project_multiword.initials).to eq 'BS'
      end
    end
  end

  describe "#set_colour" do
    let(:project) { create(:project) }
    it "sets random colour in hex format" do
      expect(project.colour).to match(/#[a-f0-9]{6}/)
    end
  end
end
