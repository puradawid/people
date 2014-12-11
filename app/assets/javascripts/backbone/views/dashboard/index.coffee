class Hrguru.Views.DashboardIndex extends Marionette.View

  el: '#main-container'

  ui:
    table: '#projects-users'
    editPopups:'#edit-membership-popups'

  initialize: ->
    @now = moment()
    @users = new Hrguru.Collections.Users(gon.users)
    @memberships = new Hrguru.Collections.Memberships(gon.memberships)
    @roles = new Hrguru.Collections.Roles(gon.roles)
    @notes = new Hrguru.Collections.Notes(gon.notes)

    _(gon.projects).each (project) =>
      project.memberships = @memberships.forProject(project.id, @roles)

    @projects = new Hrguru.Collections.Projects(gon.projects)

    @projects.each (project) =>
      project.get('notes').each (note) =>
        note.set { user: @users.get(note.get('user_id')) }

    @listenTo @projects, 'add', @addProject, this

    @render()

  render: ->
    @bindUIElements()
    @fillTable()
    @filtersView = new Hrguru.Views.Dashboard.Filters(@projects, @roles, @users)
    @filtersView.render()

  addProject: (project) ->
    view = new Hrguru.Views.Dashboard.ProjectWrapper
        model: project
        roles: @roles
        users: @users
    $el = view.render().$el
    if project.isPotential()
      $el.addClass('potential')
      $el.hide() unless @filtersView.displayedType == project.type()
    $('.open-all-notes').after($el)

  fillTable: ->
    if H.currentUserIsAdmin()
      @ui.table.append(new Hrguru.Views.Dashboard.NewProject(collection: @projects).render().$el)
      @ui.table.append(new Hrguru.Views.Dashboard.OpenAllNotes().render().$el)
    @projects.each (project) =>
      view = new Hrguru.Views.Dashboard.ProjectWrapper
        model: project
        memberships: @memberships
        roles: @roles
        users: @users
      $viewEl = view.render().$el
      unless project.isActive()
        $viewEl.addClass(project.type())
        $viewEl.hide()
      @ui.table.append($viewEl)
