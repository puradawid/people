require 'spec_helper'

describe AbilitiesController do
  before(:each) do
    role = create(:role, name: "developer", admin: true)
    sign_in create(:user, role_id: role.id)
  end

  describe "#index" do
    render_views

    before do
      create(:ability, name: "Ruby")
      create(:ability, name: "Rspec")
    end

    it "exposes abilities" do
      get :index
      expect(controller.abilities.count).to be 2
    end

    it "should display abilities on view" do
      get :index
      expect(response.body).to match /Ruby/
      expect(response.body).to match /Rspec/
    end

    context "user" do
      let(:role2) { build(:role, name: "dev", admin: false) }
      before { sign_in create(:user, role_id: role2.id) }

      it "has no access without admin rights" do
        get :index
        response.should redirect_to(root_path)
      end
    end
  end

  describe "#create" do
    context "with valid attributes" do
      subject { attributes_for(:ability, name: 'Ruby') }

      it "creates a new ability" do
        expect { post :create, ability: subject }.to change(Ability, :count).by(1)
      end
    end

    context "with invalid attributes" do
      subject { attributes_for(:ability_invalid) }

      it "does not save" do
        expect { post :create, ability: subject }.to_not change(Ability, :count)
      end
    end
  end

  describe '#update' do
    let!(:ability) { create(:ability, name: "Ruby") }

    it "exposes ability" do
      put :update, id: ability, ability: ability.attributes
      expect(controller.ability).to eq ability
    end

    context "valid attributes" do
      it "changes ability's attributes" do
        put :update, id: ability, ability: attributes_for(:ability, name: "RoR")
        ability.reload
        expect(ability.name).to eq "RoR"
      end
    end

    context "invalid attributes" do
      it "does not change ability's attributes" do
        put :update, id: ability, ability: attributes_for(:ability, name: nil)
        ability.reload
        expect(ability.name).to eq "Ruby"
      end
    end
  end
end
