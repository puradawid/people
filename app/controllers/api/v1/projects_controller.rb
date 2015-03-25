module Api::V1
  class ProjectsController < ApiController
    expose(:projects) { projects_repository.all }
    expose(:project)
  end
end

