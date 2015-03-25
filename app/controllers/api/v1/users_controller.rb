module Api::V1
  class UsersController < ApiController
    expose_decorated(:users) { users_repository.active }
    expose_decorated(:user) { users_repository.from_api(params).items.first }

    def index
      if params.fetch(:filter, {}).try(:fetch, :employment_type, nil)
        self.users = User.contract_users(params[:filter][:employment_type])
      end
    end
  end
end
