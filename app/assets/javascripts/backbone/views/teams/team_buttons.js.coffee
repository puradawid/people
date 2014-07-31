class Hrguru.Views.TeamButtons extends Marionette.ItemView

  template: JST['teams/team_buttons']

  ui:
    name:      '.name'
    form:      '.js-new-team-form'
    add:       '.js-new-team-add'

  events:
    'click .new-team-add, .new-team-close' : 'toggleFormClass'
    'click .new-team-submit' : 'addTeam'

  initialize: (options) ->
    @collection = options.collection

  onRender: ->
    @ui.form.hide()

  toggleFormClass: ->
    @ui.form.stop().fadeToggle('fast')
    @ui.add.toggleClass('clicked')
    @clearInputs()

  addTeam: ->
    attributes =
      name: @ui.name.val()
    @collection.create attributes,
      wait: true
      success: @teamCreated
      error: @teamError

  teamCreated: (team) =>
    team_name = team.get('name')
    Messenger().success("#{team_name} has been created")
    @toggleFormClass()

  teamError: =>
    Messenger().error("Error")
    @toggleFormClass()
