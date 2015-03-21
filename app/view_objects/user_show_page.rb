class UserShowPage
  attr_accessor :user, :user_membership_repository, :projects_repository, :locations_repository, :abilities_repository, :roles_repository

  def initialize(user, user_membership_repository, projects_repository, locations_repository, abilities_repository, roles_repository)
    self.user = user
    self.user_membership_repository = user_membership_repository
    self.projects_repository = projects_repository
    self.locations_repository = locations_repository
    self.abilities_repository = abilities_repository
    self.roles_repository = roles_repository
  end

  def user_gravatar
    return if user.gravatar.nil?
    user.gravatar_image class: "img-rounded", alt: user.name
  end

  def editing_enabled?(current_user)
    current_user.admin? || current_user == user
  end

  def contract_types
    @contract_types ||= ContractTypesRepository.new.all
  end

  def user_roles
    @user_roles ||= UserRolesRepository.new(user).all
  end

  def available_roles
    @available_roles ||= roles_repository.all
  end

  def abilities
    @abilities ||= AbilitiesRepository.new.ordered_by_user_abilities(raw_user)
  end

  def positions
    @positions ||= PositionDecorator.decorate_collection UserPositionsRepository.new(raw_user).all
  end

  def locations
    @locations ||= LocationsRepository.new.all
  end

  def new_membership
    user_membership_repository.build(role: user_roles.first)
  end

  def active_projects
    projects_repository.active_sorted
  end

  def projects_with_notes
    projects_repository.with_notes
  end

  def user_active_projects
    user_project_repository.active_with_memberships.map do |project, ms|
      [project, MembershipDecorator.decorate_collection(ms)]
    end
  end

  def user_archived_projects
    user_project_repository.archived_with_memberships.map do |project, ms|
      [project, MembershipDecorator.decorate_collection(ms)]
    end
  end

  private

  def user_project_repository
    @user_project_repository ||= UserProjectRepository.new(raw_user, user_membership_repository, projects_repository)
  end

  def raw_user
    user.model
  end
end
