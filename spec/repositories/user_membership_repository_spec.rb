require 'spec_helper'

describe UserMembershipRepository do
  subject { UserMembershipRepository.new(user) }
  let!(:user) { create(:user) }

  context 'potential' do
    let!(:potential_project) { create(:project, potential: true) }
    let!(:not_potential_project) { create(:project, potential: false) }
    let(:potential_membership) { create(:membership, project: potential_project, user: user) }
    let(:not_potential_membership) do
      create(:membership, project: not_potential_project, user: user)
    end

    before do
      potential_membership # lazy load
      not_potential_membership # lazy load
    end

    describe '#potential' do
      it 'returns potential memberships' do
        expect(subject.potential.items.to_a).to eq [potential_membership]
      end
    end

    describe '#not_potential' do
      it 'returns non-potential memberships' do
        expect(subject.not_potential.items.to_a).to eq [not_potential_membership]
      end
    end
  end

  context 'archived' do
    let!(:archived_project) { create(:project, archived: true) }
    let!(:not_archived_project) { create(:project, archived: false) }
    let(:archived_membership) { create(:membership, project: archived_project, user: user) }
    let(:not_archived_membership) do
      create(:membership, project: not_archived_project, user: user)
    end

    before do
      archived_membership # lazy load
      not_archived_membership # lazy load
    end

    describe '#archived' do
      it 'returns archived memberships' do
        expect(subject.archived.items.to_a).to eq [archived_membership]
      end
    end

    describe '#not_archived' do
      it 'returns non-archived memberships' do
        expect(subject.not_archived.items.to_a).to eq [not_archived_membership]
      end
    end
  end

  context 'booked' do
    let(:booked_membership) { create(:membership, user: user, booked: true) }
    let(:not_booked_membership) { create(:membership, user: user, booked: false) }

    before do
      booked_membership # lazy load
      not_booked_membership # lazy load
    end

    describe '#booked' do
      it 'returns booked memberships' do
        expect(subject.booked.items.to_a).to eq [booked_membership]
      end
    end

    describe '#not_booked' do
      it 'returns non-booked memberships' do
        expect(subject.not_booked.items.to_a).to eq [not_booked_membership]
      end
    end
  end

  context 'with_end_date' do
    let!(:membership_with_end_date) { create(:membership, user: user) }
    let!(:membership_without_end_date) { create(:membership_without_ends_at, user: user) }

    describe '#with_end_date' do
      it 'returns with_end_date memberships' do
        expect(subject.with_end_date.items.to_a).to eq [membership_with_end_date]
      end
    end

    describe '#not_with_end_date' do
      it 'returns memberships without end date' do
        expect(subject.not_with_end_date.items.to_a).to eq [membership_without_end_date]
      end
    end

    describe '#without_end_date' do
      it 'is alias to #not_with_end_date' do
        expect(subject.not_with_end_date.items.to_a).to eq subject.without_end_date.items.to_a
      end
    end
  end

  describe '#not_ended' do
    let(:not_ended_membership) do
      create(:membership, user: user, ends_at: Time.local(2014, 12, 30))
    end
    let(:ended_membership) do
      create(:membership, user: user, ends_at: Time.local(2014, 11, 30))
    end
    let(:membership_without_end_date) { create(:membership, user: user, ends_at: nil) }

    before do
      Timecop.freeze(Time.local(2014, 12, 1))
    end

    after { Timecop.return }

    it 'returns ended memberships' do
      not_ended_membership # lazy load
      expect(subject.not_ended.items.to_a).to eq [not_ended_membership]
    end
  end

  describe 'started' do
    let(:started_membership) do
      create(:membership, user: user, starts_at: Time.local(2014, 11, 30))
    end
    let(:not_started_membership) do
      create(:membership, user: user, starts_at: Time.local(2014, 12, 30))
    end

    before do
      started_membership # lazy load
      not_started_membership # lazy load
      Timecop.freeze(Time.local(2014, 12, 1))
    end

    describe '#started' do
      it 'returns started memberships' do
        expect(subject.started.items.to_a).to eq [started_membership]
      end
    end

    describe '#not_started' do
      it 'returns not started memberships' do
        expect(subject.not_started.items.to_a).to eq [not_started_membership]
      end
    end
  end

  describe '#current' do
    let!(:not_potential_or_archived_project1) do
      create(:project, archived: false, potential: false)
    end
    let!(:not_potential_or_archived_project2) do
      create(:project, archived: false, potential: false, end_at: '2014-11-11')
    end

    let(:current_membership_with_end_date) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 11, 30), ends_at: Time.local(2014, 12, 29),
        project: not_potential_or_archived_project1)
    end
    let(:current_membership_without_end_date) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 11, 30), ends_at: Time.local(2014, 12, 30),
        project: not_potential_or_archived_project2)
    end
    let(:not_started_membership) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 12, 30), ends_at: Time.local(2015, 1, 30),
        project: not_potential_or_archived_project1)
    end

    before do
      Timecop.freeze(Time.local(2014, 12, 1))
      # lazy load
      current_membership_with_end_date
      current_membership_without_end_date
      not_started_membership
    end
    it 'returns current memberships' do
      expect(subject.current.items.to_a).to(
        eq [current_membership_with_end_date, current_membership_without_end_date])
    end

    it 'returns memberships which are not potential, not archived, started and not ended' do
      expect(subject.current.items.to_a).to(
        eq subject.not_potential.not_archived.started.not_ended.items.to_a)
    end
  end

  describe '#next' do
    let!(:not_potential_or_archived_project1) do
      create(:project, archived: false, potential: false)
    end
    let!(:not_potential_or_archived_project2) do
      create(:project, archived: false, potential: false)
    end
    let(:next_membership_with_end_date) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 12, 30), ends_at: Time.local(2015, 1, 30),
        project: not_potential_or_archived_project1)
    end
    let(:next_membership_without_end_date) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 12, 30), ends_at: nil,
        project: not_potential_or_archived_project2)
    end
    let(:started_membership) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 11, 30), ends_at: Time.local(2014, 12, 29),
        project: not_potential_or_archived_project1)
    end

    before do
      Timecop.freeze(Time.local(2014, 12, 1))
      # lazy load
      next_membership_with_end_date
      next_membership_without_end_date
      started_membership
    end

    it 'returns next memberships' do
      expect(subject.next.items.to_a).to(
        eq [next_membership_with_end_date, next_membership_without_end_date])
    end

    it 'returns memberships which are not started, not ended, not potential and not booked' do
      expect(subject.next.items.to_a).to(
        eq subject.not_started.not_ended.not_potential.not_booked.items.to_a)
    end
  end

  describe '#items' do
    let(:membership) { create(:membership) }
    it 'clears search params' do
      subject.stub(:clear_search)
      subject.items
      expect(subject).to have_received(:clear_search)
    end

    it 'returns membership search results' do
      expect(subject.items).to eq MembershipSearch.new(user: user).results
    end
  end
end
