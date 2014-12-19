class AddMongoIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :mongo_id, :string
  end
end
