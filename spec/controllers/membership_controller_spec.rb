require 'spec_helper'

describe MembershipsController do
  before(:each) do
    admin = create(:admin_role)
    sign_in create(:user, admin_role_id: admin.id)
    @request.env['HTTP_REFERER'] = memberships_path
  end

  describe "#index" do
    render_views

    let!(:user) { create(:user, first_name: "Tomek") }
    let!(:project) { create(:project_deleted, name: "hrguru") }
    let!(:role_1) { create(:role, name: "junior1") }
    let!(:role_2) { create(:role, name: "junior2") }

    before do
      create(:membership, user: user, project: project, role: role_1)
      create(:membership, role: role_2)
    end

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "exposes memberships" do
      get :index
      expect(controller.memberships.count).to be 2
    end

    it "should display memberships on view" do
      get :index
      expect(response.body).to match /junior/
      expect(response.body).to match /hrguru/
      expect(response.body).to match /Tomek/
    end
  end

  describe "#new" do
    before { get :new }

    it "responds successfully with an HTTP 200 status code" do
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "exposes new membership" do
      expect(controller.membership.created_at).to be_nil
    end
  end

  describe "#create" do
    let(:params) do
      attrs = build(:membership).attributes.except('_id')
      attrs.each { |key, value| attrs[key] = value.to_s }
      attrs
    end

    context "with valid attributes" do
      it "creates a new membership" do
        expect { post :create, membership: params }.to change(Membership, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "does not save" do
        params["role_id"] = "data"
        expect { post :create, membership: params }.to_not change(Membership, :count)
      end
    end

    context "params starts_at Date picker" do
      it "saves ends_at value as end of day" do
        attributes = params.merge( ends_at: Date.new(2002, 10, 26) )
        post :create, membership: attributes
        expect(Membership.last.ends_at.to_i).to eq Date.parse('2002-10-26').end_of_day.to_i
      end
    end

    describe "json format" do
      render_views
      subject { response }

      context 'valid params' do
        before { post :create, membership: params, format: :json }

        its(:status) { should be 200 }

        it 'returns json' do
          %w(project_id role_id user_id).each do |key|
            expect(json_response[key]).to eql params[key]
          end
          %w(starts_at ends_at).each do |key|
            expect(Time.parse(json_response[key])).to eql Time.parse(params[key])
          end
        end
      end


      context 'invalid params' do
        let(:invalid_params) do
          params[:ends_at] = (Time.parse(params['starts_at']) - 1.day).to_s
          params
        end
        before { post :create, membership: invalid_params, format: :json }

        its(:status) { should be 400 }

        it 'returns error messages' do
          expect(json_response['errors']).to be_present
        end
      end
    end
  end

  describe "#destroy" do
    let!(:membership) { create(:membership) }

    it "deletes the membership" do
      expect { delete :destroy, id: membership }.to change(Membership, :count).by(-1)
    end
  end

  describe '#update' do
    let!(:membership) { create(:membership, starts_at: Time.new(2002, 10, 1, 15, 2), ends_at: Time.new(2002, 10, 28, 15, 2)) }

    it "exposes membership" do
      put :update, id: membership, membership: membership.attributes
      expect(controller.membership).to eq membership
    end

    context "valid attributes" do
      it "changes membership's range" do
        attributes = { ends_at: Time.new(2002, 10, 26, 15, 2) }
        put :update, id: membership, membership: attributes
        membership.reload
        expect(membership.ends_at.day).to eq 26
      end
    end

    context "invalid attributes" do
      it "does not change membership's attributes" do
        put :update, id: membership, membership: attributes_for(:membership, project_id: nil)
        membership.reload
        expect(membership.project).to be
      end
    end

    context "params starts_at Date picker" do
      it "saves ends_at value as end of day" do
        attributes = { ends_at: Date.new(2002, 10, 26) }
        put :update, id: membership, membership: attributes
        membership.reload
        expect(membership.ends_at.to_i).to eq Date.parse('2002-10-26').end_of_day.to_i
      end
    end

    describe "json format" do
      render_views
      subject { response }
      before { put :update, id: membership, membership: params, format: :json }

      context 'valid params' do
        let(:params) { { ends_at: Time.new(2002, 10, 26, 15, 2).to_s } }

        its(:status) { should be 200 }

        it 'returns json' do
          expect(Time.parse(json_response['ends_at']).to_s).to eql params[:ends_at]
        end
      end

      context 'invalid params' do
        let(:params) { { ends_at: Time.new(2001, 10, 26, 15, 2).to_s } }

        its(:status) { should be 400 }

        it 'returns json' do
          expect(json_response['errors']).to be_present
        end
      end
    end
  end
end
