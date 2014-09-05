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

  describe "#by_user_name_and_date" do
    let(:pos1) { mock_model(Position, user: nil, role: nil)  }
    let(:pos2) { mock_model(Position, user: nil, role: nil)  }
    let(:pos3) { mock_model(Position, user: nil, role: nil)  }
    let(:positions) { [pos1, pos2, pos3] }
    context "by_user_name_and_date" do

      it "not return error when user is nil" do
        expect(Position.by_user_name_and_date(positions)).to eq([])
      end
      context "sorts positions" do
        let(:new_role) { build(:role, name: 'new', technical: true) }
        let(:first_user) { build(:user, first_name: 'Andrew', last_name: 'Snow', role_id: new_role.id) }
        let(:second_user) { build(:user, first_name: 'Tony', last_name: 'Second', role_id: new_role.id) }
        let(:first_pos) { build(:position, user: first_user, role: new_role, 
          starts_at: Date.new(2014, 7, 14)) }
        let(:second_pos) { build(:position, user: second_user, role: new_role, 
          starts_at: Date.new(2014, 6, 11)) }
        let(:all_pos) { [first_pos, second_pos] }

        it "in the right order" do
          expect(Position.by_user_name_and_date(all_pos)).to eq([second_pos,first_pos])
        end
      end
    end
  end
end
