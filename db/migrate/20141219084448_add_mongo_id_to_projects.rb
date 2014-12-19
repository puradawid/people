class AddMongoIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :mongo_id, :string
  end
end
