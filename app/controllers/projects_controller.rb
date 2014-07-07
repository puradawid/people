class ProjectsController < ApplicationController

  expose(:project, attributes: :project_params)
  expose(:projects_sorted) { Project.by_name }
  expose(:projects)        { Project.all }

  before_filter :authenticate_admin!, only: [:update, :create, :destroy, :new, :edit]

  def create
    if project.save
      respond_on_success 'create'
    else
      respond_on_failure 'create'
    end
  end

  def show
    gon.events = get_events
  end

  def update
    if project.save
      respond_on_success 'update'
    else
      respond_on_failure 'update'
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

  def respond_on_success(action_type)
     respond_to do |format|
        format.html { redirect_to project, notice: I18n.t('projets.success', type: action_type) }
        format.json { render :show }
      end
  end

  def respond_on_failure(action_type)
    respond_to do |format|
      format.html { render :new, alert: I18n.t('projets.error',  type: action_type) }
      format.json { render json: { errors: project.errors }, status: 400 }
    end
  end

  def project_params
    params.require(:project).permit(:name, :slug, :end_at, :archived, :potential, :kickoff)
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
