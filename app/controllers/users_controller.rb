class UsersController < ApplicationController
  expose_decorated(:user) { User.find(params[:id]) }
  expose(:users) { fetch_users }
  expose(:roles) { Role.all }
  expose(:admin_role) { [AdminRole.first_or_create] }
  expose(:locations) { Location.all }
  expose(:projects) { Project.includes(:notes).all }
  expose(:unarchived_projects) { Project.where(archived: false) }
  expose(:sorted_unarchived_projects) { Project.where(archived: false).sort_by { |project| project.name.downcase } }
  expose(:abilities) { fetch_abilities }
  expose(:contractTypes) { ContractType.all }
  expose(:positions) { PositionDecorator.decorate_collection(user.positions) }

  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  def index
    gon.users = Rabl.render(users, 'users/index', view_path: 'app/views', format: :hash)
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.admin_role = admin_role
    gon.locations = locations
    gon.abilities = Ability.all
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
      @membership = Membership.new(user: user, role: user.roles.first)
      gon.events = fetch_events
    else
      redirect_to users_path, alert: 'Permission denied! You have no rights to do this.'
    end
  end

  private

  def fetch_events
    @events ||= user.memberships.includes(:project).map do |m|
      if m.project.present?
        event = { text: m.project.name, startDate: m.starts_at.to_date }
        event[:endDate] = m.ends_at.to_date if m.ends_at
        event[:user_id] = m.user.id.to_s
        event[:billable] = m.billable
        event
      end
    end
    @events.compact
  end

  def fetch_users
    @users ||= User
      .includes(:roles, :admin_role, :location, :contract_type, :memberships, :abilities)
      .all.by_last_name.decorate
  end

  def fetch_abilities
    Ability.ordered_by_user_abilities(user)
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
