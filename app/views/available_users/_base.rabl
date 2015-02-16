cache ["base", root_object]
attributes :id, :name, :email, :role, :admin_role, :employment, :phone, :location, :contract_type, :archived, :abilities,
           :next_memberships, :current_memberships, :booked_memberships, :available_since
node(:info) { |user| user.info }
node(:notes) { |user| simple_format(user.user_notes) }
node(:role_name) { |user| user.roles.first.name }
