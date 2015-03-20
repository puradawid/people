class UsersController < ApplicationController
  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  expose(:user_repository) { UserRepository.new }
  expose(:user_entity) { user_repository.get params[:id]}
  expose(:user) { UserDecorator.new(user_entity) }
  expose(:users) { UserDecorator.decorate_collection(user_repository.active) }

  expose(:roles_repository) { RolesRepository.new }
  expose(:roles) { roles_repository.all }
  # FIXME: investigate why do we need an array here and don't use array
  expose(:admin_role) { [roles_repository.get_admin] }
  expose(:locations) { LocationsRepository.new.all }
  expose(:projects_repository) { ProjectsRepository.new }
  expose(:projects) { projects_repository.with_notes }
  expose(:active_projects) { projects_repository.active_sorted }

  expose(:abilities_repository) { AbilitiesRepository.new }
  expose(:abilities) { abilities_repository.ordered_by_user_abilities(user_entity) }

  expose(:contract_types) { ContractTypesRepository.new.all }
  expose(:user_positions_repository) { UserPositionsRepository.new(user_entity) }
  expose(:positions) { PositionDecorator.decorate_collection(user_positions_repository.all) }

  def index
    gon.users = Rabl.render(users, 'users/index', view_path: 'app/views', format: :hash)
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.admin_role = admin_role
    gon.locations = locations
    gon.abilities = abilities_repository.all
    gon.months = months
  end

  def update
    user.attributes = user_params
    if user.save
      info = { notice: t('users.updated') }
    else
      info = { alert: generate_errors }
    end
    respond_to do |format|
      format.html { redirect_to user, info }
      format.json
    end
  end

  def show
    if current_user? || current_user.admin?
      @membership = UserMembershipRepository.new(user).build(role: user.roles.first)
      gon.events = user_events
    else
      redirect_to users_path, alert: 'Permission denied! You have no rights to do this.'
    end
  end

  private

  def user_events
    user_membership_repository = UserMembershipRepository.new(user_entity)
    UserEventsRepository.new(user_membership_repository).all
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :primary_role_id,
      :admin_role_id, :team_id, :leader_team_id,
      :employment, :phone, :location_id, :contract_type_id, :user_notes,
      :archived, :skype, ability_ids: [], role_ids: [])
  end

  def generate_errors
    errors = []
    errors << user.errors.messages.map { |key, value| "#{key}: #{value[0]}" }.first
    errors.join
  end

  def months
    result = []
    result << { value: 0, text: 'Show all'}
    result << { value: 1, text: '1 month'}
    (2..12).each do |n|
      result << { value: n, text: "#{n} months" }
    end
    result
  end
end
