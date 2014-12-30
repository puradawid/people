class RemoveVacations < ActiveRecord::Migration
  def up
    drop_table :vacations
  end

  def down
    create_table "vacations", force: true do |t|
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.string   "eventid"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "mongo_id"
    end
    add_index "vacations", ["user_id"], name: "index_vacations_on_user_id", using: :btree
  end
end
