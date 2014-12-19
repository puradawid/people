class AddMongoIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :mongo_id, :string
  end
end
