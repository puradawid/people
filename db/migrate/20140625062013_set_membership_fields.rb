class SetMembershipFields < Mongoid::Migration
  def self.up
    Project.all.each do |p|
      p.memberships.each do |membership|
        membership.update(project_potential: p.potential, project_archived: p.archived)
      end
    end
  end

  def self.down
  end
end
