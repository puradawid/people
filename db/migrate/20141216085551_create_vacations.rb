class CreateVacations < ActiveRecord::Migration
  def change
    create_table :vacations do |t|
      t.datetime :starts_at, type: Date
      t.datetime :ends_at, type: Date
      t.string :eventid
      t.integer :user_id
      t.timestamps
    end
    add_index :vacations, :user_id
  end
end
