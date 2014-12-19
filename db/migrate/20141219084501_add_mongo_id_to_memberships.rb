class AddMongoIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :mongo_id, :string
  end
end
