class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :role_id
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :billable
      t.boolean :project_archived, default: false
      t.boolean :project_potential, default: true
      t.boolean :project_internal, default: true
      t.boolean :stays, default: false
      t.boolean :booked, default: false
      t.timestamps
    end

    add_index :memberships, :user_id
    add_index :memberships, :project_id
    add_index :memberships, :role_id
  end
end
