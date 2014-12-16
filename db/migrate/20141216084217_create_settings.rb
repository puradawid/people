class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :notifications_email
      t.timestamps
    end
  end
end
