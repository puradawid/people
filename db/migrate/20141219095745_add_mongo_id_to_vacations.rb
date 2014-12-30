class AddMongoIdToVacations < ActiveRecord::Migration
  def change
    add_column :vacations, :mongo_id, :string
  end
end
