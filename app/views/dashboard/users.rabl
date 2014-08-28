collection users
attributes :id, :first_name, :last_name, :name, :email, :role_id, :team_id, :leader_team_id, :days_in_current_team, :archived
node(:gravatar) { |user| user.gravatar_url(30) }
