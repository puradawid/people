class AddMongoIdToAdminRoles < ActiveRecord::Migration
  def change
    add_column :admin_roles, :mongo_id, :string
  end
end
