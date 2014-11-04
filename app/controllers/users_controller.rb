class UsersController < ApplicationController
  expose_decorated(:user) { User.find(params[:id]) }
  expose(:users) { fetch_users }
  expose(:roles) { Role.all }
  expose(:admin_role) { [AdminRole.first_or_create] }
  expose(:locations) { Location.all }
  expose(:projects) { Project.includes(:notes).all }
  expose(:abilities) { fetch_abilities }
  expose(:contractTypes) { ContractType.all }
  expose(:positions) { PositionDecorator.decorate_collection(user.positions) }

  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  def index
    gon.rabl as: 'users'
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.admin_role = admin_role
    gon.locations = locations
    gon.abilities = Ability.all

    respond_to do |format|
      format.html
      format.csv
    end
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
      @membership = Membership.new(user: user, role: user.role)
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
        event[:billable] = m.billable
        event
      end
    end
    @events.compact
  end

  def fetch_users
    @users ||= User
      .includes(:role, :admin_role, :location, :contract_type, :memberships)
      .all.by_last_name.decorate
  end

  def fetch_abilities
    @abilities ||= Ability.ordered_by_user_abilities(user).map(&:name)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role_id, :admin_role_id, :team_id, :leader_team_id,
      :employment, :phone, :location_id, :contract_type_id,
      :archived, :skype, abilities_names: [])
  end

  def generate_errors
    errors = []
    errors << user.errors.messages.map { |key, value| "#{key}: #{value[0]}" }.first
    errors.join
  end
end
