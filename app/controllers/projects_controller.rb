class ProjectsController < ApplicationController
  include Shared::RespondsController

  before_filter :authenticate_admin!, except: [:show]

  expose(:project, attributes: :project_params)

  def create
    if project.save
      respond_on_success project
    else
      respond_on_failure project.errors
    end
  end

  def show
    gon.project = project
    gon.events = get_events
  end

  def update
    if project.save
      respond_on_success project
    else
      respond_on_failure project.errors
    end
  end

  def destroy
    if project.destroy && project.potential
      redirect_to(projects_url, notice: I18n.t('projects.success',  type: 'delete'))
    else
      redirect_to(projects_url, alert: I18n.t('projects.error',  type: 'delete'))
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :slug, :end_at, :archived, :potential,
      :kickoff, :project_type, :toggl_bookmark, :internal,
      memberships_attributes: [:id, :stays, :user_id, :role_id, :starts_at, :billable])
  end

  def get_events
    project.memberships.map do |m|
      event = { text: m.user.decorate.name, startDate: m.starts_at.to_date }
      event[:user_id] = m.user.id.to_s
      event[:endDate] = m.ends_at.to_date if m.ends_at
      event[:billable] = m.billable
      event
    end
  end
end
