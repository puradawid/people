require 'spec_helper'
describe Api::V1::UsersController do
  render_views
  before { controller.class.skip_before_filter :authenticate_api! }

  let!(:user) { create(:user) }
  let(:user_keys) { ["first_name", "last_name", "email", "contract_type", "archived", "abilities", "role", "memberships"] }

  let!(:senior) { create(:role, name: 'senior') }
  let!(:developer) { create(:role, name: 'developer') }
  let!(:junior) { create(:role, name: 'junior') }

  let!(:membership1) { create(:membership, user: user, role: junior) }

  let!(:membership2) { create(:membership, user: user, role: developer) }
  let!(:membership3) { create(:membership,
                             user: user,
                             role: senior,
                             project: membership2.project,
                             starts_at: membership2.ends_at + 1.day,
                             ends_at: membership2.ends_at + 2.days) }

  describe "GET #index" do

    before do
      get :index, format: :json
      @json_response = JSON.parse(response.body)
    end

    it "returns 200 code" do
      expect( response.status ).to eq 200
    end

    it 'contains current user fields' do
      expect(@json_response.first.keys).to eq(user_keys)
    end

    context 'in each membership' do
      subject { @json_response[0]['memberships'] }

      it 'includes last user role' do
        subject.each do |memb|
          expect(memb[1]['role']).to be_in %w(junior senior)
        end
      end

      it 'includes project slug' do
        subject.each do |memb|
          expect(memb[1]['slug']).to\
            be_in [membership1.project.slug, membership2.project.slug]
        end
      end
    end
  end

  shared_examples_for "GET #show" do |attribute|
    describe "using #{attribute}" do
      before do
        execute_request
        @json_response = JSON.parse(response.body)
      end

      it "returns 200 code" do
        expect( response.status ).to eq 200
      end

      it "contains current_week fields" do
        expect(@json_response.keys).to eq(user_keys)
      end
    end
  end

  it_should_behave_like "GET #show", :id do
    let!(:execute_request) { get :show, id: user.id, format: :json }
  end
  it_should_behave_like "GET #show", :email do
    let!(:execute_request) { get :show, id: 1, email: user.email, format: :json }
  end
end
