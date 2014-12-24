class Hrguru.Models.User extends Backbone.Model

  visibleBy:
    users: true
    roles: true
    projects: true
    abilities: true
    months_in_current_project: true

  membership: null

  initialize: ->
    super
    @set('daysToEndMembership', -1)
    @next_projects = new Hrguru.Models.Project(@get('next_projects'))
    @initMembership()
    @listenTo(EventAggregator, 'users:updateVisibility', @updateVisibility)

  initMembership: ->
    return unless @get('membership')
    @membership = new Hrguru.Models.Membership(@get('membership'))
    if @membership.started && @membership.hasEndDate()
      @set('daysToEndMembership', @membership.daysToEnd())

  updateVisibility: (data) ->
    @visibleBy.roles = @visibleByRoles(data.roles)
    @visibleBy.projects = @visibleByProjects(data.projects)
    @visibleBy.users = @visibleByUsers(data.users)
    @visibleBy.abilities = @visibleByAbilities(data.abilities)
    @visibleBy.months_in_current_project = @visibleByMonthsInCurrentProject(parseInt(data.months))
    @trigger 'toggle_visible', @isVisible()

  isVisible: ->
    @visibleBy.roles && @visibleBy.projects && @visibleBy.users &&
      @visibleBy.abilities && @isActive() && @visibleBy.months_in_current_project

  visibleByUsers: (users) ->
    return true if users.length < 1
    @id in users

  visibleByRoles: (roles) ->
    return true if roles.length < 1
    return false unless @get('role')?
    @get('role')._id in roles

  visibleByProjects: (projects) ->
    return true if projects.length < 1
    return false unless @get('projects')?
    myProjects = @myProjects()
    (_.difference myProjects, projects).length < myProjects.length

  visibleByAbilities: (abilities) ->
    return true if abilities.length < 1
    return false unless @get('abilities')?
    myAbilities = @myAbilities()
    (_.difference myAbilities, abilities).length < myAbilities.length

  visibleByMonthsInCurrentProject: (months) ->
    return true if months == 0
    @isInProjectForMoreThanMonths(months)

  myProjects: ->
    _.map @get("projects"), (p) -> p.project._id

  myAbilities: ->
    _.map @get("abilities"), (a) -> a._id

  isActive: ->
    !@get('archived')

  hasRole: ->
    @get('role_id') != null

  isInProjectForMoreThanMonths: (months) ->
    return true if isNaN(months)
    @get('months_in_current_project') > months

  hasTechnicalRole: ->
    @get('role').technical

  isPotential: ->
    return false unless @hasTechnicalRole()
    if @get('has_project') && !@hasProjectsOnlyPotentialOrNotbillable()
      return false unless @get('daysToEndMembership') < 30 && @membership.hasEndDate()
    (!@hasNextProjects() || @nextProjectsOnlyPotentialOrNotbillable())

  hasNextProjects: ->
    @next_projects?

  hasProjectsOnlyPotentialOrNotbillable: ->
    @areOnlyPotenialOrNotbillable(@get('projects'))

  nextProjectsOnlyPotentialOrNotbillable: ->
    @areOnlyPotenialOrNotbillable(@next_projects)

  areOnlyPotenialOrNotbillable: (projects) ->
    _.all projects, (project) =>
      @userProjectIsPotential(project) or !@userProjectIsBillable(project)

  userProjectIsPotential: (next_project) ->
    next_project.project.potential

  userProjectIsBillable: (current_project) ->
    current_project.billable

class Hrguru.Collections.Users extends Backbone.Collection
  model: Hrguru.Models.User
  url: Routes.users_path()

  sortAttribute: 'name'
  sortDirection: 1

  sortUsers: (attr, direction = 1) ->
    @sortAttribute = attr
    @sortDirection = direction
    @sort()
    return

  comparator: (a, b) ->
    a = a.get(@sortAttribute)
    b = b.get(@sortAttribute)
    a = '' unless a
    b = '' unless b

    if @sortDirection is 1
      a.localeCompare(b)
    else
      b.localeCompare(a)

  active: ->
    filtered = @filter((user) ->
      user.isActive()
    )
    new Hrguru.Collections.Users(filtered)

  withRole: ->
    filtered = @filter((user) ->
      user.hasRole()
    )
    new Hrguru.Collections.Users(filtered)
