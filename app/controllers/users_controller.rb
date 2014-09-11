class UsersController < ApplicationController
  expose_decorated(:user) { User.find(params[:id]) }
  expose(:users) { User.all.by_last_name.decorate }
  expose(:roles) { Role.all }
  expose(:locations) { Location.all }
  expose(:projects) { Project.all }
  expose(:abilities) { Ability.ordered_by_user_abilities(user).map(&:name) }
  expose(:contractTypes) { ContractType.all }
  expose(:positions) { PositionDecorator.decorate_collection(user.positions) }

  before_filter :authenticate_admin!, only: [:update], unless: -> { current_user? }

  def index
    gon.rabl as: 'users'
    gon.rabl template: 'app/views/users/projects', as: 'projects'
    gon.roles = roles
    gon.locations = locations

    respond_to do |format|
      format.html
      format.csv
    end
  end

  def update
    user.attributes = user_params
    if user.save
      info = { notice: t('users.updated') }
      json = user
      status = 200
    else
      info = { alert: generate_errors }
      json = { errors: user.errors.messages }
      status = :unprocessable_entity
    end
    respond_to do |format|
      format.html { redirect_to user, info }
      format.json { render json: json, status: status }
    end
  end

  def show
    if current_user? || current_user.admin?
      @membership = Membership.new(user: user, role: user.role)
      gon.events = get_events
    else
      redirect_to users_path, alert: 'Permission denied! You have no rights to do this.'
    end
  end

  private

  def get_events
    events = user.memberships.map do |m|
      if m.project.present?
        event = { text: m.project.name, startDate: m.starts_at.to_date }
        event[:endDate] = m.ends_at.to_date if m.ends_at
        event[:billable] = m.billable
        event
      end
    end
    events.compact
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :role_id, :team_id, :leader_team_id,
                                 :employment, :phone, :location_id, :contract_type_id,
                                 :archived, :skype, abilities_names: [])
  end

  def generate_errors
    errors = []
    errors << user.errors.messages.map { |key, value| "#{key}: #{value[0]}" }.first
    errors.join
  end
end
