require 'spec_helper'

describe Position do
  subject { build(:position, starts_at: Time.now) }

  it { should belong_to :role }
  it { should belong_to :user }
  it { should be_valid }

  describe "#available roles" do
    let(:juniorRole) { create(:role, name: "junior", technical: true) }
    let!(:seniorRole) { create(:role, name: "senior", technical: true) }
    let!(:user) { create(:user, role_id: juniorRole.id) }

    context "available roles" do

      it "returns available roles when user has no possition assigned" do
        pos = create(:position, user: user)
        expect(pos.available_roles).to include juniorRole
        expect(pos.available_roles).to include seniorRole
      end

      it "returns available roles when user has possition assigned" do
        create(:position, user: user, role: juniorRole, starts_at: Time.now)
        pos = create(:position, user: user)
        expect(pos.available_roles).to include seniorRole
        expect(pos.available_roles).to_not include juniorRole
      end
    end
  end

  describe "#validate chronology" do
    let(:juniorRole) { create(:role, name: "junior", technical: true) }
    let!(:seniorRole) { create(:role, name: "senior", technical: true) }
    let!(:user) { create(:user, role_id: juniorRole.id) }
    let!(:juniorPos) { create(:position, user: user, role: juniorRole, starts_at: Date.new(2014, 5, 14)) }
    context "validate chronology" do

      it "return error when dates are wrong" do
        pos = build(:position, user: user, role: seniorRole, starts_at: juniorPos.starts_at - 2.days)
        expect(pos).not_to be_valid
        expect(pos.errors).not_to be_blank
        expect(pos.errors).to include :starts_at
        expect(pos.errors[:starts_at]).to include I18n.t('positions.errors.chronology')
      end

      it "should not return error when dates chronology is ok" do
        senior_pos = build(:position, user: user, role: seniorRole, starts_at: juniorPos.starts_at + 2.days)
        expect(senior_pos).to be_valid
        expect(senior_pos.errors).to be_blank
      end
    end
  end
end
