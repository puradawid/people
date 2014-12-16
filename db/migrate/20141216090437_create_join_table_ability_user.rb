class CreateJoinTableAbilityUser < ActiveRecord::Migration
  def change
    create_join_table :abilities, :users do |t|
      t.index :user_id
      t.index :ability_id
    end
  end
end
