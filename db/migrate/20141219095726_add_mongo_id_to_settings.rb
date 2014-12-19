class AddMongoIdToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :mongo_id, :string
  end
end
