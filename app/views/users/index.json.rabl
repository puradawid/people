collection users

extends "users/base"

node(:gravatar) { |user| user.gravatar_image(size: 40) }
node(:github) { |user| user.github_link(icon: true) }
node(:projects) { |user| user.current_projects }
node(:membership) { |user| user.current_memberships.sort_by(&:ends_at).reverse!.last }
node(:has_project) { |user| user.has_current_projects? }
node(:has_next_project) { |user| user.has_next_projects? }
node(:has_potential_project) { |user| user.has_potential_projects? }
node(:next_projects) { |user| user.next_projects }
node(:potential_projects) { |user| user.potential_projects }
