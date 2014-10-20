attributes :name, :archived, :potential, :toggl_bookmark

node :slug do |project|
  project.api_slug
end
