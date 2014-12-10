require 'spec_helper'

describe MembershipDecorator do
  let(:membership) { create(:membership).decorate }
  let(:old_membership) {create(:membership, starts_at: '2002-10-01', ends_at: '2002-11-02').decorate }

  describe '#user_name' do
    it { expect(membership.user_name).to eq("#{membership.user.name}") }
  end

  describe '#duration_in_words' do
    it { expect(old_membership.duration_in_words).to eq("about 1 month") }
  end

  describe '#date_range' do
    it { expect(old_membership.date_range).to eq("<i class=\"fa fa-calendar \"></i> 2002-10-01 ... 2002-11-02") }
  end

  describe '#project_name' do
    it { expect(membership.project_name).to eq("#{membership.project.name}") }
  end

  describe '#role_name' do
    it { expect(membership.role_name).to eq("#{membership.role.name}") }
  end
end
