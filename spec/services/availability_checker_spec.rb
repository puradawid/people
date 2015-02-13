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
    context 'when user has' do
      context 'no membership' do
        before { subject.run! }

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(Date.today)
        end
      end

      context 'only nonbillable membership' do
        before do
          create(:membership, ends_at: nil, user: user, project: project)
          subject.run!
        end

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(Date.today)
        end
      end

      context 'only internal project' do
        let!(:membership) { create(:membership, ends_at: 1.month.from_now, user: user, project: internal_project) }
        before { subject.run! }

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(Date.today)
        end
      end

      context 'billable membership' do
        context 'with end date' do
          let!(:membership) { create(:membership_billable, ends_at: 35.days.from_now, user: user, project: project_without_end_date) }
          before { subject.run! }

          it 'changes user availability to true' do
            expect(user.available).to be_true
            expect(user.available_since).to eq(membership.ends_at + 1)
          end
        end

        context 'without end date' do
          before do
            create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date)
            subject.run!
          end

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be nil
          end
        end

        context 'without end date in project with end date' do
          before do
            create(:membership_billable, ends_at: nil, user: user, project: project_ending)
            subject.run!
          end

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end
      end

      context 'nonbillable and billable memberships' do
        context 'billable with end date, nonbillable without end' do
          let!(:billable) do
            create(:membership_billable, ends_at: 2.months.from_now, user: user, project: project_without_end_date2)
          end
          let!(:nonbillable) { create(:membership, ends_at: nil, user: user, project: project_without_end_date) }

          before { subject.run! }

          it 'changes user availability to true' do
            expect(user.available).to be_true
          end

          it 'is available when billable is done' do
            expect(user.available_since).to eq(billable.ends_at + 1)
          end
        end

        context 'billable without end, nonbillable with end date' do
          let!(:billable) do
            create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date2)
          end
          let!(:nonbillable) { create(:membership, ends_at: 2.weeks.from_now, user: user, project: project_without_end_date) }

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end

        context 'both without end date' do
          let!(:membership) { create(:membership, ends_at: nil, user: user, project: project_without_end_date) }
          let!(:membership_billable) { create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date2) }

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end
      end

      context '2 billable memberships' do
        context 'one after another, second with end date' do
          let!(:membership) { create(:membership_billable, starts_at: 3.days.from_now, ends_at: 2.months.from_now, user: user, project: project_without_end_date) }
          let!(:membership2) { create(:membership_billable, ends_at: 1.day.from_now, user: user, project: project_without_end_date2) }
          before { subject.run! }

          it 'changes user available since to last possible date' do
            expect(user.available).to be_true
            expect(user.available_since).to eq(membership2.ends_at + 1)
          end
        end

        context 'one after another, second without end date' do
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

        context 'with at least 1 day gap between them' do
          let!(:first_membership) do
            create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project_without_end_date)
          end
          let!(:second_membership) do
            create(:membership_billable, starts_at: 4.days.from_now, ends_at: nil, user: user, project: project_without_end_date2)
          end

          before { subject.run! }

          it 'changes user availability to true' do
            expect(user.available).to be_true
            expect(user.available_since).to eq(first_membership.ends_at + 1)
          end
        end

        context 'with no gap between them' do
          before do
            create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project_without_end_date)
            create(:membership_billable, starts_at: 3.days.from_now, ends_at: nil, user: user, project: project_without_end_date2)
            subject.run!
          end

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end
      end

      context 'many memberships' do
        context 'all billable and overlapping' do
          let!(:membership) { create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project) }
          let!(:membership2) { create(:membership_billable, ends_at: nil, user: user, project: project_ending) }
          let!(:membership3) { create(:membership_billable, ends_at: nil, user: user, project: project_without_end_date) }

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end

        context 'many memberships in the past, one without end right now' do
          let!(:first) do
            create(:membership_billable, starts_at: '2015-02-10',
                                         ends_at: nil,
                                         user: user,
                                         project: project)
          end
          let!(:second) do
            create(:membership_billable, starts_at: '2014-12-29',
                                         ends_at: '2015-01-21',
                                         user: user,
                                         project: project)
          end
          let!(:third) do
            create(:membership_billable, starts_at: '2014-10-26',
                                         ends_at: '2014-11-18',
                                         user: user,
                                         project: project)
          end
          let!(:fourth) do
            create(:membership_billable, starts_at: '2014-08-31',
                                         ends_at: '2014-09-27',
                                         user: user,
                                         project: project)
          end
          let!(:fifth) do
            create(:membership_billable, starts_at: '2014-05-09',
                                         ends_at: '2014-05-23',
                                         user: user,
                                         project: project)
          end

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to eq(nil)
          end
        end
      end
    end
  end
end
