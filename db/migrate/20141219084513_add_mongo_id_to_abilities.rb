class AddMongoIdToAbilities < ActiveRecord::Migration
  def change
    add_column :abilities, :mongo_id, :string
  end
end
