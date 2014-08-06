class Hrguru.Views.TeamButtons extends Marionette.CompositeView
  template: JST['teams/team_buttons']
  itemView: Hrguru.Views.TeamUser
  itemViewContainer: '#users-body'

  ui:
    name:         '.name'
    form:         '.js-new-team-form'
    usersTable:   '.js-users-table'
    add:          '.js-new-team-add'

  events:
    'click .new-team-add, .new-team-close'  : 'toggleFormClass'
    'click .new-team-submit'                : 'addTeam'
    'click .show-users'                     : 'toggleUserTable'

  initialize: (options) ->
    @teams = options.teams
    @roles = options.roles

  itemViewOptions: ->
    roles: @roles
    tagName: 'div'
    className: 'col-md-2'
    noUI: true

  onRender: ->
    @ui.form.hide()
    @ui.usersTable.hide()

  toggleUserTable: ->
    @ui.usersTable.toggle()

  toggleFormClass: ->
    @ui.form.stop().fadeToggle('fast')
    @ui.add.toggleClass('clicked')
    $(@ui.form).find('input').val('')

  addTeam: ->
    attributes =
      name: @ui.name.val()
    @teams.create attributes,
      wait: true
      success: @teamCreated
      error: @teamError

  teamCreated: (team, response) =>
    team.set('id', response._id)
    team_name = team.get('name')
    Messenger().success("#{team_name} has been created")
    @toggleFormClass()

  teamError: (team, response) =>
    Messenger().error(response.responseJSON.errors.name[0])
    @toggleFormClass()
