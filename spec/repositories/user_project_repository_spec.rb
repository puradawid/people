require 'spec_helper'

describe UserProjectRepository do
  subject { described_class.new(user, user_membership_repository, projects_repository) }
  let(:user_membership_repository) { UserMembershipRepository.new(user) }
  let(:projects_repository) { ProjectsRepository.new }
  let!(:user) { create(:user) }

  describe '#potential' do
    let!(:potential_project) { create(:project, potential: true) }
    let!(:potential_membership) { create(:membership, user: user, project: potential_project) }
    let!(:not_potential_membership) { create(:membership, user: user) }

    it 'returns potential projects that the user has memberships in' do
      expect(subject.potential.items.to_a).to eq [potential_project]
    end
  end

  describe '#next' do
    let!(:next_project) { create(:project, archived: false, potential: false) }
    let!(:next_membership) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 12, 30), ends_at: Time.local(2015, 1, 30),
        project: next_project)
    end
    let!(:not_next_membership) { create(:membership, user: user, starts_at: Time.local(2014, 10, 10)) }

    before { Timecop.freeze(2014, 12, 1) }

    it 'returns next projects that the user has memberships in' do
      expect(subject.next.items.to_a).to eq [next_project]
    end
  end

  describe '#current' do
    let!(:current_project) { create(:project, archived: false, potential: false) }
    let!(:current_membership) do
      create(:membership,
        user: user, starts_at: Time.local(2014, 11, 30), ends_at: Time.local(2014, 12, 29),
        project: current_project)
    end
    let!(:not_current_membership) { create(:membership) }

    before { Timecop.freeze(2014, 12, 1) }

    it 'returns current proects that the user has memberships in' do
      expect(subject.current.items.to_a).to eq [current_project]
    end
  end

  describe '#items' do
    let!(:membership) { create(:membership) }

    it 'returns ProjectSearch results' do
      expect(subject.items.to_a).to eq ProjectSearch.new(memberships: [membership]).results.to_a
    end
  end
end
