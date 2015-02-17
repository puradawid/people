require 'spec_helper'

describe MembershipCollision do
  context 'creating membership when it overlaps other' do
    let!(:role) { create(:role_billable) }
    let!(:user) { create(:user, primary_role: role) }
    let(:project) { create(:project) }
    let!(:first_membership) { create(:membership_billable, user: user, project: project) }
    let!(:second_membership) { build(:membership_billable, user: user, project: project) }

    before { described_class.new(second_membership).call! }

    it 'return error when creating second membership' do
      expect(
        second_membership.errors[:project]
      ).to include('user is not available at given time for this project')
    end
  end

  context 'when client requests junior to stay as dev' do
    let!(:junior_role) { create(:junior_role) }
    let!(:user) { create(:user, primary_role: junior_role) }
    let(:project) { create(:project) }
    let!(:first_membership) { create(:membership, user: user, project: project) }
    let!(:second_membership) { build(:membership_billable, :booked, user: user, project: project) }

    before { described_class.new(second_membership).call! }

    it 'does not return any errors' do
      expect(
        second_membership.errors
      ).to be_blank
    end
  end
end
