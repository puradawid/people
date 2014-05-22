object current_user
attributes :id, :name
node(:admin) { !!current_user.try(:admin?) }
node(:gravatar) { |user| user.gravatar_url(40) }
