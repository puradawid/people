require 'spec_helper'

describe ProjectSearch do
  describe '#search_potential' do
    let!(:potential_project) { create(:project, potential: true) }
    let!(:other_project) { create(:project, potential: false) }

    it 'returns potential projects when potential is true' do
      expect(described_class.new(potential: true).results.to_a).to eq [potential_project]
    end

    it 'returns other projects when potential is false' do
      expect(described_class.new(potential: false).results.to_a).to eq [other_project]
    end
  end

  describe '#search_archived' do
    let!(:archived_project) { create(:project, archived: true) }
    let!(:other_project) { create(:project, archived: false) }

    it 'returns archived projects when archived is true' do
      expect(described_class.new(archived: true).results.to_a).to eq [archived_project]
    end

    it 'returns other projects when archived is false' do
      expect(described_class.new(archived: false).results.to_a).to eq [other_project]
    end
  end

  describe '#search_memberships' do
    let!(:project_1) { create(:project) }
    let!(:user) { create(:user) }
    let!(:membership) { create(:membership, user: user, project: project_1) }
    let!(:project_2) { create(:project) }

    it 'returns projects that own the passed memberships' do
      expect(described_class.new(memberships: [membership]).results.to_a).to eq [project_1]
    end
  end
end
