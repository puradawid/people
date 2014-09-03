class Hrguru.Views.TeamButtons extends Marionette.CompositeView
  template: JST['teams/team_buttons']

  ui:
    name:         '.name'
    form:         '.js-new-team-form'
    add:          '.js-new-team-add'

  events:
    'click .new-team-add, .new-team-close'  : 'toggleFormClass'
    'click .new-team-submit'                : 'addTeam'

  initialize: (options) ->
    @teams = options.teams
    @roles = options.roles

  onRender: ->
    @ui.form.hide()

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
