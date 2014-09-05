class ProjectsController < ApplicationController

  include Shared::RespondsController

  expose(:project, attributes: :project_params)
  expose(:projects_sorted) { Project.by_name }
  expose(:projects)        { Project.all }

  before_filter :authenticate_admin!, only: [:update, :create, :destroy, :new, :edit]

  def create
    if project.save
      respond_on_success project
    else
      respond_on_failure project.errors
    end
  end

  def show
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
                                    :kickoff, :project_type,
                                    memberships_attributes: [:id, :stays])
  end

  def get_events
    project.memberships.map do |m|
      event = { text: m.user.decorate.name, startDate: m.starts_at.to_date }
      event[:endDate] = m.ends_at.to_date if m.ends_at
      event[:billable] = m.billable
      event
    end
  end
end
