attributes :first_name, :last_name, :email, :archived

node :role do |user|
  user.role.try(:name)
end

node :contract_type do |user|
  user.contract_type.try(:name)
end

node :memberships do |user|
  user.flat_memberships
end

child :abilities do
  attributes :name
end

