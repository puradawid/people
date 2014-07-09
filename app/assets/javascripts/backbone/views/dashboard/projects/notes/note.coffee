class Hrguru.Views.Dashboard.Note extends Marionette.ItemView

  template: JST['dashboard/projects/notes/note']

  className: 'project-note'

  triggers:
    'click .note-remove' : 'remove:note:clicked'
    'click .note-close'  : 'close:note:clicked'

  initialize: (options) ->
    @user = @options.users.get(@model.get('user_id'))

  serializeData: ->
    _.extend super,
      user: @user

  onRemoveNoteClicked: ->
    return unless confirm('Are you sure?')
    @model.destroy
      success: => @onSuccess('deleted')
      error: @onError

  onCloseNoteClicked: ->
    attribute = open: !@model.get('open')
    text = if @model.get('open') then 'closed' else 'opened'
    @model.save attribute,
      patch: true
      success: => @onSuccess(text)
      error: @onError
    @render()

  onSuccess: (text) ->
    Messenger().success("Note has been #{text}.")

  onError: (note, request) ->
    error_massage = _.map request.responseJSON.errors, (value, key) =>
      "#{key}: " + _.map value, (msg) =>
        msg
    Messenger().error(error_massage.join())
