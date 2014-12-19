class AddMongoIdToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :mongo_id, :string
  end
end
