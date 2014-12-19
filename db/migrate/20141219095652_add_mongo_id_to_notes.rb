class AddMongoIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :mongo_id, :string
  end
end
