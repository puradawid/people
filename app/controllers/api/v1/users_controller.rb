class Api::V1::UsersController < Api::V1::ApiController
  expose(:users) { User.all }
  expose(:user) { User.get_from_api params }

  def index
  end

  def show
  end

  def contract_users
    render :json => User.contract_users.to_a
  end
end
