require 'spec_helper'

describe MembershipSearch do
  describe '#search_user' do
    let!(:user) { create(:user) }
    let!(:membership) { create(:membership, user: user) }
    let!(:other_membership) { create(:membership) }

    it 'returns memberships that belong to the user' do
      expect(described_class.new(user: user).results.to_a).to eq [membership]
    end
  end

  describe '#search_archived' do
    let!(:archived_project) { create(:project, archived: true) }
    let!(:membership) { create(:membership, project: archived_project) }
    let!(:other_membership) { create(:membership) }

    it 'returns memberships that belong to archived projects' do
      expect(described_class.new(archived: true).results.to_a).to eq [membership]
    end
  end

  describe '#search_potential' do
    let!(:potential_project) { create(:project, potential: true) }
    let!(:membership) { create(:membership, project: potential_project) }
    let!(:other_membership) { create(:membership) }

    it 'returns memberships that belong to potential projects' do
      expect(described_class.new(potential: true).results.to_a).to eq [membership]
    end
  end

  describe '#search_ends_later_than' do
    let!(:later_membership) { create(:membership, ends_at: Time.local(2014, 12, 30), starts_at: Time.local(2014, 11, 29)) }
    let!(:earlier_membership) { create(:membership, ends_at: Time.local(2014, 11, 30), starts_at: Time.local(2014, 11, 29)) }

    before { Timecop.freeze(Time.local(2014, 12, 1)) }

    it 'returns memberships which end later than specified time' do
      expect(described_class.new(ends_later_than: Time.now).results.to_a).to eq [later_membership]
    end
  end

  describe '#search_starts_earlier_than' do
    let!(:later_membership) { create(:membership, starts_at: Time.local(2014, 12, 30)) }
    let!(:earlier_membership) { create(:membership, starts_at: Time.local(2014, 11, 30)) }

    before { Timecop.freeze(Time.local(2014, 12, 1)) }

    it 'returns memberships which start earlier than specified time' do
      expect(described_class.new(starts_earlier_than: Time.now).results.to_a).to(
        eq [earlier_membership])
    end
  end

  describe '#search_starts_later_than' do
    let!(:later_membership) { create(:membership, starts_at: Time.local(2014, 12, 30)) }
    let!(:earlier_membership) { create(:membership, starts_at: Time.local(2014, 11, 30)) }

    before { Timecop.freeze(Time.local(2014, 12, 1)) }

    it 'returns memberships which start later than specified time' do
      expect(described_class.new(starts_later_than: Time.now).results.to_a).to(
        eq [later_membership])
    end
  end

  describe '#search_booked' do
    let!(:booked_membership) { create(:membership, booked: true) }
    let!(:other_membership) { create(:membership) }

    it 'returns booked memberships' do
      expect(described_class.new(booked: true).results.to_a).to eq [booked_membership]
    end
  end

  describe '#search_with_end_date' do
    let!(:membership_with_end_date) { create(:membership) }
    let!(:membership_without_end_date) { create(:membership_without_ends_at) }

    it 'when true it returns memberships with end date' do
      expect(described_class.new(with_end_date: true).results.to_a).to eq [membership_with_end_date]
    end

    it 'when true it returns memberships with end date' do
      expect(described_class.new(with_end_date: false).results.to_a).to(
        eq [membership_without_end_date])
    end
  end
end
