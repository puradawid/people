class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :color
      t.boolean :billable, default: false
      t.boolean :technical, default: false
      t.boolean :show_in_team, default: true
      t.timestamps
    end
  end
end
