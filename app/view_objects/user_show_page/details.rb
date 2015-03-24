class UserShowPage
  class Details
    attr_accessor :user, :roles_repository, :contract_types_repository,
      :locations_repository, :user_positions_repository, :user_roles_repository,
      :abilities_repository

    def initialize(user:, roles_repository:, contract_types_repository:,
                   locations_repository:, user_positions_repository:,
                   user_roles_repository:, abilities_repository:)
      self.user = user
      self.roles_repository = roles_repository
      self.contract_types_repository = contract_types_repository
      self.locations_repository = locations_repository
      self.abilities_repository = abilities_repository
      self.user_positions_repository = user_positions_repository
      self.user_roles_repository = user_roles_repository
    end

    def contract_types
      @contract_types ||= contract_types_repository.all
    end

    def locations
      @locations ||= locations_repository.all
    end

    def positions
      @positions ||= PositionDecorator.decorate_collection(user_positions_repository.all)
    end

    def user_roles
      user_roles_repository.all
    end

    def editing_enabled?(current_user)
      current_user.admin? || current_user == user
    end

    def abilities
      abilities_repository.ordered_by_user_abilities(user)
    end

    def available_roles
      @available_roles ||= roles_repository.all
    end
  end
end
