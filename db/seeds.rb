require 'factory_girl'
require 'faker'

Dir[Rails.root.join("spec/factories/*.rb")].each {|f| require f}

billable_roles = %w(senior developer)
non_billable_roles = %w(junior praktykant pm junior\ pm qa junior\ qa)
technical_roles = %w(junior praktykant developer senior)
admin_roles = %w(senior pm)
contract_types = %w(DG UoP UoD)
locations = %w(Poznan Warsaw Gdansk Zielona\ Gora Krakow Remotely)

billable_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:billable, true)
end

non_billable_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:billable, false)
end

technical_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:technical, true)
end

admin_roles.each do |name|
  Role.find_or_create_by(name: name).update_attribute(:admin, true)
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

FactoryGirl.create_list(:user, 50) if Rails.env.development?

