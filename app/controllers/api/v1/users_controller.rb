class Api::V1::UsersController < Api::V1::ApiController
  expose(:users) { User.all }
  expose(:user) { User.get_from_api params }

  def index
    if params.fetch(:filter, {})[:employment_type]
      render json: User.contract_users(params[:filter][:employment_type])
    end
  end

  def show
  end
end
