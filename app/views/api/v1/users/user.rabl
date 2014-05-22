attributes :id, :first_name, :last_name, :email, :contract_type, :archived, :abilities

node :role do |u|
  u.role.try(:name)
end

node :memberships do |u|
  u.flat_memberships
end
