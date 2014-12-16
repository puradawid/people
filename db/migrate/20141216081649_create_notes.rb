class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :project_id
      t.integer :user_id
      t.text :text
      t.boolean :open, default: true
      t.timestamps
    end

    add_index :notes, :project_id
    add_index :notes, :user_id
  end
end
