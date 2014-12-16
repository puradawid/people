class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.datetime :end_at
      t.boolean :archived, default: false
      t.boolean :potential, default: false
      t.boolean :internal, default: false
      t.datetime :kickoff
      t.string :project_type
      t.string :colour
      t.string :initials
      t.string :toggl_bookmark
      t.timestamps
    end
  end
end
