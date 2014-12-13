module Api::V1
  class MembershipsController < Api::V1::ApiController

    expose(:membership, attributes: :membership_params)
    expose(:memberships) { Membership.all }

    def create
      membership.save
      respond_with membership
    end

    def update
      membership.save
      respond_with membership
    end

    def destroy
      membership.destroy
      respond_with membership
    end

    private

    def membership_params
      params.require(:membership).permit!
    end
  end
end
