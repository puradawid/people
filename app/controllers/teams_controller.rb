class TeamsController < ApplicationController
  include Shared::RespondsController
  expose(:team, attributes: :team_params)
  expose(:teams)
  expose(:users_without_team) { User.where(team_id: nil) }

  def index
  end

  def create
    if team.save
      respond_on_success teams_path
    else
      respond_on_failure team.errors
    end
  end

  def new
  end

  def edit
  end

  def update
    if team.save
      respond_on_success teams_path
    else
      respond_on_failure team.errors
    end
  end

  def show
  end

  def destroy
    if team.destroy
      respond_on_success teams_path
    else
      respond_on_failure team.errors
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, user_ids: [])
  end
end
