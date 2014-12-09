attributes :id, :name, :email, :role, :admin_role, :employment, :phone, :location, :contract_type, :archived, :abilities
node(:info) { |user| user.info }
node(:months_in_current_project) { |user| user.months_in_current_project }
