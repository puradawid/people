class ProjectsController < ApplicationController

  expose(:project, attributes: :project_params)
  expose(:projects_sorted) { Project.by_name }
  expose(:projects)        { Project.all }

  before_filter :authenticate_admin!, only: [:update, :create, :destroy, :new, :edit]

  def create
    if project.save
      respond_to do |format|
        format.html { redirect_to project, notice: 'Project created!' }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :new, alert: 'Something went wrong. Create unsuccessful' }
        format.json { render json: { errors: project.errors }, status: 400 }
      end
    end
  end

  def show
    gon.events = get_events
  end

  def update
    if project.save
      respond_to do |format|
        format.html { redirect_to project, notice: 'Project updated!' }
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :edit, alert: 'Something went wrong. Update unsuccessful' }
        format.json { render json: { errors: project.errors }, status: 400 }
      end
    end
  end

  def destroy
    if project.destroy && project.potential
      redirect_to(projects_url, notice: 'Project deleted!')
    else
      redirect_to(projects_url, alert: 'Something went wrong. Delete unsuccessful')
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :end_at, :archived, :potential, :kickoff)
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
