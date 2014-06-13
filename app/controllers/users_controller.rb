class UsersController < ApplicationController
  expose_decorated(:user, attributes: :user_params)
  expose(:users) { User.all.decorate }
  expose(:roles) { Role.all }
  expose(:locations) { Location.all }
  expose(:projects) { Project.all }
  expose(:abilities) { Ability.ordered_by_user_abilities(user).map(&:name) }
  expose(:contractTypes) { ContractType.all }
  expose(:positions) { PositionDecorator.decorate_collection(user.positions) }

  before_filter :authenticate_admin!, only: [:update], unless: -> { user == current_user }

  def index
    gon.rabl as: 'users'
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.locations = locations
  end

  def update
    if user.save
      respond_to do |format|
        format.html { redirect_to user, notice: "User updated." }
        format.json { render json: {} }
      end
    else
      respond_to do |format|
        format.html do
          errors = []
          errors << user.errors.messages.map { |key, value| "#{key}: #{value[0]}" }.first
          redirect_to user, alert: errors.join
        end
        format.json { render json: { errors: user.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  def show
    @membership = Membership.new(user: user, role: user.role)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role_id, :employment, :phone,
                                 :location_id, :contract_type_id, :archived, :skype, abilities_names: [])
  end
end
