class AddMongoIdToContractTypes < ActiveRecord::Migration
  def change
    add_column :contract_types, :mongo_id, :string
  end
end
