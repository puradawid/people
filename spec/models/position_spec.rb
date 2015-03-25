require 'spec_helper'

describe Position do
  subject { build(:position, starts_at: Time.now) }

  it { should belong_to :role }
  it { should belong_to :user }
  it { should be_valid }

  describe 'role validation' do
    let(:juniorRole) { create(:role, name: 'junior', technical: true) }
    let!(:seniorRole) { create(:role, name: 'senior', technical: true) }
    let!(:user) { create(:user, primary_role: juniorRole) }

    it "doesn't allow to set a given role when user has this role already" do
      create(:position, user: user, role: juniorRole, starts_at: Time.now)
      pos = create(:position, user: user)
      pos.role = juniorRole
      expect(pos).to_not be_valid
    end

    it 'allows to set any role when there is no position assigned' do
      pos = create(:position, user: user)
      pos.role = juniorRole
      expect(pos).to be_valid
      pos.role = seniorRole
      expect(pos).to be_valid
    end
  end

  describe '#validate chronology' do
    let(:juniorRole) { create(:role, name: 'junior', technical: true) }
    let!(:seniorRole) { create(:role, name: 'senior', technical: true) }
    let!(:user) { create(:user, primary_role: juniorRole) }
    let!(:juniorPos) { create(:position, user: user, role: juniorRole, starts_at: Date.new(2014, 5, 14)) }

    it 'returns error when dates are wrong' do
      pos = build(:position, user: user, role: seniorRole, starts_at: juniorPos.starts_at - 2.days)
      expect(pos).not_to be_valid
      expect(pos.errors).not_to be_blank
      expect(pos.errors).to include :starts_at
      expect(pos.errors[:starts_at]).to include I18n.t('positions.errors.chronology')
    end

    it 'returns error when no "Starts at" provided and some position exists' do
      senior_position = build(:position, user: user, role: seniorRole, starts_at: nil)
      expect(senior_position).to_not be_valid
      expect(senior_position.errors[:starts_at]).to include("can't be blank")
    end

    it 'will not return error when dates chronology is ok' do
      senior_pos = build(:position, user: user, role: seniorRole, starts_at: juniorPos.starts_at + 2.days)
      expect(senior_pos).to be_valid
      expect(senior_pos.errors).to be_blank
    end
  end
end
