cache ["base", root_object]
attributes :id, :name, :email, :primary_role, :admin_role, :employment, :phone, :location, :contract_type, :archived, :abilities,
           :next_memberships, :current_memberships, :booked_memberships, :available_since
node(:info) { |user| user.info }
node(:notes) { |user| user.user_notes.present? ? simple_format(user.user_notes) : ''  }
node(:role) { |user| user.primary_role }
node(:role_name) { |user| user.primary_role.try(:name) }
