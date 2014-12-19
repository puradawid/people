class Api::V1::UsersController < Api::V1::ApiController
  expose_decorated(:users) { User.all }
  expose_decorated(:user) { user_repository.from_api(params).items.first }

  def index
    if params.fetch(:filter, {}).try(:fetch, :employment_type, nil)
      self.users = User.contract_users(params[:filter][:employment_type])
    end
  end

  def show
  end

  private

  def user_repository
    @user_repository ||= UserRepository.new
  end
end
