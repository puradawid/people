class UsersController < ApplicationController
  include ContextFreeRepos
  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  expose(:user) { users_repository.get params[:id] }
  expose(:users) { UserDecorator.decorate_collection(users_repository.active) }
  # FIXME: this is a bad way, we can't access repo from user model!
  expose(:user_membership_repository) { UserMembershipRepository.new(user) }
  expose(:user_positions_repository) { UserPositionsRepository.new(user) }
  expose(:user_projects_repository) do
    UserProjectRepository.new(user, user_membership_repository, projects_repository)
  end
  expose(:user_roles_repository) { UserRolesRepository.new(user) }
  expose(:new_membership_page) do
    UserShowPage::NewMembership.new(
      user: user,
      roles_repository: roles_repository,
      user_membership_repository: user_membership_repository,
      user_roles_repository: user_roles_repository,
      projects_repository: projects_repository
    )
  end
  expose(:user_show_page) do
    UserShowPage.new(
      user: user,
      projects_repository: projects_repository,
      user_projects_repository: user_projects_repository,
    )
  end
  expose(:user_details_page) do
    UserShowPage::Details.new(
      user: user,
      roles_repository: roles_repository,
      locations_repository: locations_repository,
      abilities_repository: abilities_repository,
      user_positions_repository: user_positions_repository,
      contract_types_repository: contract_types_repository,
      user_roles_repository: user_roles_repository,
    )
  end

  def index
    setup_gon_for_index
  end

  def update
    # TODO: extract to service object - make sure it saves abilities
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
    gon.events = user_events
  end

  private

  def user_events
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

  def setup_gon_for_index
    projects_a = projects_repository.with_notes
    gon.users = Rabl.render(users, 'users/index', view_path: 'app/views', format: :hash)
    gon.projects = Rabl.render(projects_a, 'users/projects', format: :hash)
    gon.roles = roles_repository.all
    gon.admin_role = roles_repository.admin_role
    gon.locations = locations_repository.all
    gon.abilities = abilities_repository.all
    gon.months = months
  end
end
