attributes :id, :name, :archived, :potential, :toggl_bookmark, :last_commit_date

node :slug do |project|
  project.api_slug
end
