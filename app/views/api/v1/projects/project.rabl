attributes :name, :archived, :potential

node :slug do |project|
  project.api_slug
end
