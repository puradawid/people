cache ["base", root_object]
attributes :id, :name, :email, :role_id, :admin_role_id, :employment, :phone, :location_id, :contract_type, :archived, :abilities
node(:info) { |user| user.info }
node(:months_in_current_project) { |user| user.months_in_current_project }
