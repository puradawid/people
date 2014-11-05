object user

extends 'users/base'

node(:gravatar) { |user| user.gravatar_url(:circle) }
