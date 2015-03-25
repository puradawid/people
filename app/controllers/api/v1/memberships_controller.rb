module Api::V1
  class MembershipsController < ApiController
    expose(:membership, attributes: :membership_params)
    expose(:memberships) { memberships_repository.all }

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
