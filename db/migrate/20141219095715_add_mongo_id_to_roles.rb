class AddMongoIdToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :mongo_id, :string
  end
end
