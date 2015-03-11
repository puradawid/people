class Hrguru.Views.ModalView extends Marionette.ItemView
  template: JST['teams/_form']

  events:
    'submit form': (e) -> @updateTeam(e)

  events:
    'click button[type="cancel"]'  : 'closeDialog'

  initialize: (options) ->
    @team = options.team

  onShow: ->
    @$el.dialog
      title: 'edit name'
      dialogClass: "no-close"
      modal: true
      resizable: false
      draggable: false
      appendTo: '#modal-region'
      show: 200
      hide: 200

  updateTeam: (e) ->
    e.preventDefault()

    newName = @$el.find('input').val()
    @team.save name: newName,
      wait: true
      success: @teamNameChanged
      error: @teamError
    @close()

  teamNameChanged: (team) =>
    Messenger().success("We successfully changed team's name to #{team.get('name')}")

  teamError: (model, xhr) ->
    Messenger().error(xhr.responseJSON.errors)

  closeDialog: (e) ->
    e.preventDefault()
    @close()
