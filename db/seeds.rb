billable_roles = ["senior", "developer"]
non_billable_roles = ["junior", "praktykant", "pm", "junior pm", "qa", "junior qa"]
contract_types = ["DG", "UoP", "UoD"]
locations = ["Poznan", "Warsaw", "Gdansk", "Zielona Gora", "Remotely"]

billable_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:billable, true)
end
non_billable_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:billable, false)
end
contract_types.each do |name|
  ContractType.find_or_create_by(name: name)
end
locations.each do |name|
  Location.find_or_create_by(name: name)
end

Membership.where(billable: nil).each do |membership|
  billable = membership.try(:role).try(:billable) || false
  membership.update_attribute(:billable, billable)
end
