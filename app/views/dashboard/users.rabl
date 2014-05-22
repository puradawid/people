collection users
attributes :id, :first_name, :last_name, :name, :email, :role_id
node(:gravatar) { |user| user.gravatar_url(30) }
