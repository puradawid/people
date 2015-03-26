describe Membership do
  subject { build(:membership, starts_at: Time.now) }

  it { should belong_to :user }
  it { should belong_to :project }
  it { should belong_to :role }
  it { should be_valid }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:role) }
  it { should be_timestamped_document }
  it { should have_field(:starts_at).of_type(Date) }
  it { should have_field(:ends_at).of_type(Date) }
  it { should have_field(:billable).of_type(Mongoid::Boolean) }
  it { should validate_inclusion_of(:billable).to_allow([true, false]) }

  describe '#validate_starts_at_ends_at' do
    it "adds an error if 'ends_at' is before 'starts_at'" do
      subject.ends_at = subject.starts_at - 2.days
      subject.send :validate_starts_at_ends_at
      expect(subject.errors[:ends_at]).to include("can't be before starts_at date")
    end
  end

  describe '#validate_duplicate_project' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:membership) { build(:membership, user: user, project: project) }

    before do
      [
        [Time.new(2013, 1, 1), Time.new(2013, 6, 1)],
        [Time.new(2013, 6, 2), Time.new(2013, 8, 30)],
        [Time.new(2013, 10, 1), nil]
      ].each { |time_range| create(:membership, user: user, project: project, starts_at: time_range[0], ends_at: time_range[1]) }
    end

    context "valid" do
      [
        [Time.new(2012, 1, 1), Time.new(2012, 6, 1)],
        [Time.new(2013, 9, 1), Time.new(2013, 9, 30)]
      ].each do |time_range|
        it "start #{time_range[0]} ends #{time_range[1]}" do
          membership.starts_at, membership.ends_at = time_range
          expect(membership).to be_valid
        end
      end
    end

    context "invalid" do
      [
        [Time.new(2012, 1, 1), nil],
        [Time.new(2013, 11, 1), nil],
        [Time.new(2013, 1, 1), Time.new(2013, 5, 1)]
      ].each do |time_range|
        it "start #{time_range[0]} ends #{time_range[1]}" do
          membership.starts_at, membership.ends_at = time_range
          expect(membership).to_not be_valid
        end
      end
    end
  end

  describe "active?" do

    subject { membership.active? }

    context "when membership is not yet started" do
      let(:membership) { build(:membership, starts_at: 2.days.from_now, ends_at: 5.months.from_now) }
      it { should be_false }
    end

    context "when membership is strated but not ended" do
      let(:membership) { build(:membership, starts_at: 1.month.ago, ends_at: 2.months.from_now) }
      it { should be_true }
    end

    context "when membership is started and has no end" do
      let(:membership) { build(:membership, starts_at: 1.month.ago, ends_at: nil) }
      it { should be_true }
    end

    context "when membership is started and ended" do
      let(:membership) { build(:membership, starts_at: 5.months.ago, ends_at: 1.week.ago) }
      it { should be_false }
    end
  end

  describe ".upcoming_changes" do
    let(:days) { 30 }
    subject { described_class.upcoming_changes(days).to_a.flatten }

    it "includes 2 upcoming changes" do
      membership1 = create :membership, starts_at: 1.week.from_now
      membership2 = create :membership, starts_at: 1.week.from_now
      membership_not_included = create :membership, starts_at: 1.year.from_now,
                                                    ends_at: 2.years.from_now
      expect(subject).to include membership1, membership2
      expect(subject).not_to include membership_not_included
    end
  end
end
