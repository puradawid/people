require 'spec_helper'

describe ProjectDigest do
  describe "#three_months_old" do
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
          expect(ProjectDigest.three_months_old).to include(project_potential)
        end
      end
    end

    context "when project has no history" do
      before { Project.any_instance.stub(:history_tracks) { [HistoryTracker.new] } }

      it "returns project" do
        Timecop.freeze(date) do
          expect(ProjectDigest.three_months_old).to include(project)
        end
      end

      it "does not return project" do
        expect(ProjectDigest.three_months_old).not_to include(project2)
      end
    end
  end

  describe "#ending_in" do
    let(:days) { 30 }
    subject { described_class.ending_in(days).to_a.flatten }

    it "returns projects ending soon" do
      project = create :project, end_at: 1.week.from_now
      expect(subject).to include project
    end
  end

  describe "#starting_in" do
    let(:days) { 30 }
    subject { described_class.starting_in(days).to_a.flatten }

    it "returns projects starting soon" do
      project = create :project, kickoff: 1.week.from_now
      expect(subject).to include project
    end
  end

  describe "#ending_or_starting_in" do
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

  describe '#starting_tommorow' do
    before do
      2.times { |t| create(:project, kickoff: Time.current + t.hours, potential: true) }

      create(:project, kickoff: Time.current + 12.hours, potential: false)
      create(:project, kickoff: Time.current + 2.days, potential: true)
    end

    it 'returns potential projects scheduled for kickoff in next 24 hours' do
      expect(ProjectDigest.starting_tommorow.count).to eq 2
    end
  end

  describe ".leaving_memberships" do
    let(:days) { 30 }
    let(:project) { create(:project) }
    subject { described_class.new(project).leaving_memberships(days) }

    it "is empty when no users are leaving" do
      expect(subject).to be_empty
    end

    it "returns memberships ending in next 30 days" do
      membership = create :membership, ends_at: 1.week.from_now, project: project
      membership1 = create :membership, ends_at: 5.weeks.from_now, project: project
      expect(subject).to include membership
      expect(subject).not_to include membership1
    end

  end

  describe ".joining_memberships" do
    let(:days) { 30 }
    let(:project) { create(:project) }
    subject { described_class.new(project).joining_memberships(days) }

    it "is empty when no users are joining" do
      expect(subject).to be_empty
    end

    it "shows one user is joining" do
      membership = create :membership, starts_at: 1.week.from_now, project: project
      expect(subject).to include membership
    end
  end
end
