class Api::V1::ProjectsController < Api::V1::ApiController
  expose(:projects) { Project.all }
  expose(:project)

  def index
  end

end
