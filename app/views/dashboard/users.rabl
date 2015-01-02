collection decorated_users
attributes :id, :first_name, :last_name, :name, :email, :role_id, :team_id, :leader_team_id, :archived, :team_join_time
node(:gravatar) { |user| user.gravatar_url(:circle) }
node(:info) { |user| user.info }
