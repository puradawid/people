class AddMongoIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mongo_id, :string
  end
end
