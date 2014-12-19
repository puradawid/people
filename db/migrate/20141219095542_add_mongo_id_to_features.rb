class AddMongoIdToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :mongo_id, :string
  end
end
