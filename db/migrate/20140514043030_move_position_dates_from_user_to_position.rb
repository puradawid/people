class MovePositionDatesFromUserToPosition < Mongoid::Migration
  def self.up
    roles = Role.all
    dev_roles = %w(senior developer junior)
    qa_roles = ['qa', 'junior qa']
    pm_roles = ['pm', 'junior pm']
    User.includes(:role).all.each do |user|
      if user.intern_start
        create_position(roles, user, 'praktykant', user.intern_start)
      end
      if user.junior_start
        if dev_roles.include?(user.role.name)
          create_position(roles, user, 'junior', user.junior_start)
        elsif qa_roles.include?(user.role.name)
          create_position(roles, user, 'junior qa', user.junior_start)
        elsif pm_roles.include?(user.role.name)
          create_position(roles, user, 'junior pm', user.junior_start)
        end
      end
      if user.dev_start
        create_position(roles, user, 'developer', user.dev_start)
      end
      if user.senior_start
        create_position(roles, user, 'senior', user.senior_start)
      end
    end
  end

  def self.down
    Position.delete_all
  end


  def self.create_position(roles, user, role_name, starts_at)
    role = roles.select { |role| role.name == role_name }.first
    position = Position.create(user: user, role: role, starts_at: starts_at)
    position.save
  end
end
