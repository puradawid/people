class MoveEmploymentTypeToContractTypeModel < Mongoid::Migration
  def self.up
    User.all.each do |user|
      begin
        employment_type = ContractType.find_by(name: user.employment_type)
        user.contract_type_id = employment_type.id
        user.save
      rescue Mongoid::Errors::DocumentNotFound
        puts "oupst, not found"
      end
    end
  end

  def self.down
  end
end
