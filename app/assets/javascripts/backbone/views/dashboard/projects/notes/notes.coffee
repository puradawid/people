class Hrguru.Views.Dashboard.Notes extends Marionette.CompositeView

  template: JST['dashboard/projects/notes/notes']

  itemView: Hrguru.Views.Dashboard.Note
  itemViewContainer: '.js-project-notes-region'

  className: 'project-notes-block'

  triggers:
    'click .new-project-note-submit' : 'add:note:clicked'

  collectionEvents:
    add: 'clearInput'

  ui:
    text: '.new-project-note-text'

  initialize: (options) ->
    @project_id = options.project_id
    @users = options.users

  itemViewOptions: ->
    users: @users

  onAddNoteClicked: ->
    attributes =
      text: @ui.text.val()
      project_id: @project_id
      user_id: H.current_user.get('id')
    @collection.create attributes,
      wait: true
      success: @noteCreated
      error: @noteError

  noteCreated: ->
    Messenger().success('A note has been created')

  noteError: (note, request) ->
    error_massage = _.map request.responseJSON.errors, (value, key) =>
      "#{key}: " + _.map value, (msg) =>
        msg
    Messenger().error(error_massage.join())

  clearInput: ->
    @ui.text.val('')
