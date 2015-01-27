require 'spec_helper'

describe AvailabilityChecker do
  subject { AvailabilityChecker.new(user) }
  let!(:user) { create(:user, role: role, available: nil) }
  let(:role) { create(:role, technical: true) }
  let(:project) { create(:project) }
  let(:internal_project) { create(:project, internal: true, potential: false) }
  let(:project_without_end_date) { create(:project, end_at: nil) }
  let(:project_without_end_date2) { create(:project, end_at: nil) }
  let(:project_ending) { create(:project, end_at: 27.days.from_now) }
  let(:project_ending_in_more_than_month) { create(:project, end_at: 40.days.from_now) }

  describe '#run!' do
    context 'when user has not memberships' do
      before do
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(Date.today)
      end
    end

    context 'when user has nonbillable membership' do
      before do
        create(:membership, ends_at: nil, user: user, project: project)
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(Date.today)
      end
    end

    context 'when user has billable memberships without end date' do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
        subject.run!
      end

      it 'changes user availability to false' do
        expect(user.available).to be_false
        expect(user.available_since).to be nil
      end
    end

    context 'when user has billable membership and is in project with end date' do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
        create(:membership_billable, ends_at: nil, user: user, project: project_ending)
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(project_ending.end_at.to_date)
      end
    end

    context 'when user has two billable memberships with end date' do
      context 'and project with end date' do
        let!(:last_membership) { create(:membership_billable, ends_at: 2.months.from_now, user: user, project: project_without_end_date) }
        before do
          create(:membership_billable, ends_at: nil, user: user, project: project_ending)
          subject.run!
        end

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(last_membership.ends_at)
        end
      end
    end

    context 'when user has membership with end date' do
      let!(:membership) { create(:membership_billable, ends_at: 35.days.from_now, user: user, project: project_without_end_date) }
      before { subject.run! }

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(membership.ends_at.to_date)
      end
    end

    context 'when user has nonbillable membership and billable membership without end date' do
      let!(:membership) { create(:membership, ends_at: nil, user: user, project: project_without_end_date) }
      let!(:membership_billable) { create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date2) }

      it 'changes user availability to false' do
        subject.run!
        expect(user.available).to be_false
      end

      it 'changes user availability to false if nonbillable project is with end date' do
        membership.project.update_attributes(end_at: 2.months.from_now)
        subject.run!
        expect(user.available).to be_false
      end
    end

    context 'when user has nonbillable membership and billable membership with end date' do
      before do
        create(:membership, ends_at: nil, user: user, project: project_without_end_date)
        create(:membership_billable, ends_at: 2.months.from_now, user: user, project: project_without_end_date2)
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
      end
    end

    context 'when user project ending is present' do
      before do
        create(:membership_billable, ends_at: nil, user: user, project: project_ending_in_more_than_month)
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(project_ending_in_more_than_month.end_at.to_date)
      end
    end

    context 'when user has billable membership without end' do
      context 'with memberships with end date' do
        let!(:membership) { create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project) }
        before do
          create(:membership_billable, ends_at: nil, user: user, project: project_ending)
          create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
          subject.run!
        end

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(project.end_at)
        end
      end
    end

    context 'when user has 2 billable memberships one after another' do
      context 'and project is ending' do
        before do
          create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project_ending)
          create(:membership_billable, ends_at: nil, starts_at: 3.days.from_now, user: user, project: project_without_end_date)
          subject.run!
        end
        it 'changes user availability to false' do
          expect(user.available).to be_false
          expect(user.available_since).to eq(nil)
        end
      end
    end

    context 'when user has no gap between 2 memberships' do
      before do
        create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project_without_end_date)
        create(:membership_billable, starts_at: 3.days.from_now, ends_at: nil, user: user, project: project_without_end_date2)
        subject.run!
      end

      it 'changes user availability to false' do
        expect(user.available).to be_false
        expect(user.available_since).to be nil
      end
    end

    context 'when user has gap between 2 memberships' do
      let!(:membership) { create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project_without_end_date) }
      before do
        create(:membership_billable, starts_at: 4.days.from_now, ends_at: nil, user: user, project: project_without_end_date2)
        subject.run!
      end

      it 'changes user availability to true' do
        expect(user.available).to be_true
        expect(user.available_since).to eq membership.ends_at.to_date
      end
    end

    context 'when user has next project' do
      let!(:membership) { create(:membership_billable, starts_at: 3.days.from_now, ends_at: 2.months.from_now, user: user, project: project_without_end_date) }
      before do
        create(:membership_billable, ends_at: 1.day.from_now, user: user, project: project_without_end_date2)
        subject.run!
      end

      it 'changes user available since to last possible date' do
        expect(user.available).to be_true
        expect(user.available_since).to eq membership.ends_at.to_date
      end
    end

    context 'when user has internal project' do
      let!(:membership) { create(:membership, ends_at: 1.month.from_now, user: user, project: internal_project) }
      before { subject.run! }

      it 'doesnt change user availablity to false' do
        expect(user.available).to be_true
        expect(user.available_since).to eq(membership.ends_at)
      end
    end
  end
end
