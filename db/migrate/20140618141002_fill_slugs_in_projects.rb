class FillSlugsInProjects < Mongoid::Migration
  def self.up
    Project.all.each do |p|
      p.update_attribute(:slug, p.name.try(:delete, '^a-zA-Z').try(:downcase))
    end
  end

  def self.down
    Project.all.each do |p|
      p.update_attribute(:slug, nil)
    end
  end
end

