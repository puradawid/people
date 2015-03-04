require 'spec_helper'

describe AvailabilityChecker do
  before do
    Timecop.freeze(Time.local(2015))
  end

  after do
    Timecop.return
  end

  subject { AvailabilityChecker.new(user) }
  let!(:user) { create(:user, primary_role: role, available: nil) }
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
        let!(:nonbillable_membership) do
          create(:membership, ends_at: nil, user: user, project: project)
        end

        before { subject.run! }

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(Date.today)
        end
      end

      context 'not technical role' do
        let!(:nonbillable_membership) do
          create(:membership, ends_at: nil, user: user, project: project)
        end

        before do
          user.primary_role.update_attribute(:technical, false)
          subject.run!
        end

        it "doesn't check availability" do
          expect(user.available).to be_nil
        end
      end

      context 'only internal project' do
        let!(:membership) { create(:membership, user: user, project: internal_project) }
        before { subject.run! }

        it 'changes user availability to true' do
          expect(user.available).to be_true
          expect(user.available_since).to eq(Date.today)
        end
      end

      context 'billable membership' do
        context 'with end date' do
          let!(:membership) do
            create(:membership_billable, user: user, project: project_without_end_date)
          end
          before { subject.run! }

          it 'changes user availability to true' do
            expect(user.available).to be_true
            expect(user.available_since).to eq(membership.ends_at + 1)
          end
        end

        context 'without end date' do
          let!(:membership) do
            create(:membership_billable, :without_end,
                                         user: user,
                                         project: project_without_end_date)
          end

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be nil
          end
        end

        context 'without end date in project with end date' do
          let!(:billable_membership) do
            create(:membership_billable, :without_end, user: user, project: project_ending)
          end

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be_nil
          end
        end

        context 'starting in the future (dev is free right now)' do
          let!(:billable_membership) do
            create(:membership_billable, :without_end,
                                         starts_at: 3.days.from_now,
                                         user: user,
                                         project: project_ending)
          end

          before { subject.run! }

          it 'changes user availability to true' do
            expect(user.available).to be_true
            expect(user.available_since).to eq(Date.today)
          end
        end
      end

      context 'nonbillable and billable memberships' do
        context 'billable with end date, nonbillable without end' do
          let!(:billable) do
            create(:membership_billable, user: user, project: project_without_end_date2)
          end
          let!(:nonbillable) do
            create(:membership, :without_end, user: user, project: project_without_end_date)
          end

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
            create(:membership_billable, :without_end,
                                         user: user,
                                         project: project_without_end_date2)
          end
          let!(:nonbillable) { create(:membership, user: user, project: project_without_end_date) }

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be_nil
          end
        end

        context 'both without end date' do
          let!(:membership) do
            create(:membership, :without_end, user: user, project: project_without_end_date)
          end
          let!(:membership_billable) do
            create(:membership_billable, :without_end,
                                         user: user,
                                         project: project_without_end_date2)
          end

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be_nil
          end
        end
      end

      context '2 billable memberships' do
        context 'with gap between them' do
          context 'both with end dates' do
            let!(:first) do
              create(:membership_billable, ends_at: 1.day.from_now,
                                           user: user,
                                           project: project_without_end_date2)
            end
            let!(:second) do
              create(:membership_billable, starts_at: 3.days.from_now,
                                           ends_at: 2.months.from_now,
                                           user: user,
                                           project: project_without_end_date)
            end

            before { subject.run! }

            it 'changes user available since to last possible date' do
              expect(user.available).to be_true
              expect(user.available_since).to eq(first.ends_at + 1)
            end
          end

          context 'second without end date' do
            let!(:first) do
              create(:membership_billable, ends_at: 2.days.from_now,
                                           user: user,
                                           project: project_ending)
            end

            let!(:second) do
              create(:membership_billable, starts_at: 4.days.from_now,
                                           user: user,
                                           project: project_without_end_date)
            end

            before { subject.run! }

            it 'changes user availability to true' do
              expect(user.available).to be_true
              expect(user.available_since).to eq(first.ends_at + 1)
            end
          end
        end

        context 'without gap between them' do
          context 'both with end dates' do
            let!(:first) do
              create(:membership_billable, ends_at: 2.days.from_now,
                                           user: user,
                                           project: project_ending)
            end

            let!(:second) do
              create(:membership_billable, starts_at: 3.days.from_now,
                                           user: user,
                                           project: project_without_end_date)
            end

            before { subject.run! }

            it 'changes user availability to true' do
              expect(user.available).to be_true
              expect(user.available_since).to eq(second.ends_at + 1)
            end
          end

          context 'second without end date' do
            let!(:first) do
              create(:membership_billable, ends_at: 2.days.from_now,
                                           user: user,
                                           project: project_ending)
            end
            let!(:second) do
              create(:membership_billable, :without_end,
                                           starts_at: 3.days.from_now,
                                           user: user,
                                           project: project_without_end_date)
            end

            before { subject.run! }

            it 'changes user availability to false' do
              expect(user.available).to be_false
              expect(user.available_since).to be_nil
            end
          end
        end
      end

      context 'many memberships' do
        context 'all billable and overlapping' do
          let!(:first) do
            create(:membership_billable, ends_at: 2.days.from_now, user: user, project: project)
          end
          let!(:second) do
            create(:membership_billable, :without_end, user: user, project: project_ending)
          end
          let!(:third) do
            create(:membership_billable, :without_end,
                                         user: user,
                                         project: project_without_end_date)
          end

          before { subject.run! }

          it 'changes user availability to false' do
            expect(user.available).to be_false
            expect(user.available_since).to be_nil
          end
        end

        context 'many memberships in the past, one without end right now' do
          let!(:first) do
            create(:membership_billable, starts_at: '2015-01-22',
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
            expect(user.available_since).to be_nil
          end
        end
      end
    end
  end
end
