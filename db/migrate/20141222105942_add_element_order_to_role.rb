class AddElementOrderToRole < ActiveRecord::Migration
  def change
    add_column :roles, :element_order, :integer, default: 0, null: false, position: :last
  end
end
