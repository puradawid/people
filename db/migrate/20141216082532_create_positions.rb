class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :user_id
      t.integer :role_id
      t.datetime :starts_at
      t.timestamps
    end

    add_index :positions, :user_id
    add_index :positions, :role_id
  end
end
