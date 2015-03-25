class Position
  class RoleValidator < ActiveModel::Validator
    def validate(record)
      if user_already_has_this_role?(record.user, record.role)
        record.errors.add(:role, I18n.t('positions.errors.role'))
      end
    end

    private

    def user_role_names(user)
      other_roles = Role.all.to_a - user_roles(user)
    end

    def user_already_has_this_role?(user, role)
      user_role_names(user).include? role.name
    end

    def user_roles(user)
      user.positions.ne(created_at: nil).map(&:role)
    end
  end
end
