attributes :name, :archived

node :slug do |project|
  project.api_slug
end
