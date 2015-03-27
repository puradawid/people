require 'rails_helper'

describe MembershipsRepository do
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
