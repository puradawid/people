require 'spec_helper'

describe AvailabilityChecker do
  subject { AvailabilityChecker.new(user) }
  let!(:user) { create(:user, role: role, available: nil) }
  let(:role) { create(:role, technical: true) }
  let(:project) { create(:project) }
  let(:project_without_end_date) { create(:project, end_at: nil) }
  let(:project_ending) { create(:project, end_at: 27.days.from_now) }
  let(:project_ending_in_more_than_month) { create(:project, end_at: 40.days.from_now) }

  describe "#run!" do
    context "when user has not memberships" do
      before do
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end

    context "when user has nonbillable membership" do
      before do
        create(:membership, ends_at: nil, user: user, project: project)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end

    context "when user has billable memberships" do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
        create(:membership_billable, user: user, project: project)
        subject.run!
      end

      it "changes user availability to false" do
        expect(user.available).to be_false
      end
    end

    context "when user membership ending" do
      before do
        create(:membership_billable, ends_at: 4.days.from_now, user: user, project: project_without_end_date)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end

    context "when user membership ending more than one month from now" do
      before do
        create(:membership_billable, ends_at: 32.days.from_now, user: user, project: project_without_end_date)
        subject.run!
      end

      it "changes user availability to false" do
        expect(user.available).to be_false
      end
    end

    context "when user membership ending les than one month from now" do
      before do
        create(:membership_billable, ends_at: 2.week.from_now, user: user, project: project_without_end_date)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end

    context "when user membership ending is nil" do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_ending)
        subject.run!
      end

      it "changes user availability to false" do
        expect(user.available).to be_false
      end
    end

    context "when user project ending more than one month" do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_ending_in_more_than_month)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_false
      end
    end

    context "when user has at least one billable membership without end" do
      before do
        create(:membership, ends_at: nil, user: user, project: project_ending)
        create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project)
        create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
        subject.run!
      end

      it "changes user availability to false" do
        expect(user.available).to be_false
      end
    end

    context "when user is on vacation" do
      let(:user) { build(:user) }
      vacation = { starts_at: Time.now-1.day, ends_at: Time.now+7.days }
      before do
        user.build_vacation(vacation)
        subject.run!
      end

      it "changes user availability to false" do
        expect(user.available).to be_false
      end
    end

    context "when user is before vacation" do
      let(:user) { build(:user) }
      vacation = { starts_at: Time.now+7.days, ends_at: Time.now+14.days }
      before do
        user.build_vacation(vacation)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end

    context "when user was on vacation" do
      let(:user) { build(:user) }
      vacation = { starts_at: Time.now-14.days, ends_at: Time.now-7.days }
      before do
        user.build_vacation(vacation)
        subject.run!
      end

      it "changes user availability to true" do
        expect(user.available).to be_true
      end
    end
  end
end
