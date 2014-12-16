class CreateAdminRole < ActiveRecord::Migration
  def change
    create_table :admin_roles do |t|
      t.timestamps
    end
  end
end
