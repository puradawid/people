class Hrguru.Views.Dashboard.NotesLayout extends Marionette.Layout

  template: JST['dashboard/projects/notes/layout']

  regions:
    notesRegion:  '.js-project-notes-region'

  ui:
    notesWrapper: '.js-project-notes-wrapper'
    openNotes:    '.js-open-project-notes'
    closeNotes:   '.js-close-project-notes'

  triggers:
    'click .js-open-project-notes'  : 'open:project:notes'
    'click .js-close-project-notes' : 'close:project:notes'

  initialize: (options) ->
    { @users, @model } = options
    @listenTo(EventAggregator, 'open:all:notes', @onOpenProjectNotes)
    @listenTo(EventAggregator, 'close:all:notes', @onCloseProjectNotes)
    @listenToOnce(EventAggregator, 'cookie:open:notes', @cookieOpenNotes)

  onRender: ->
    @ui.notesWrapper.hide()
    @ui.closeNotes.hide()
    notesView = new Hrguru.Views.Dashboard.Notes
      collection: @model.get('notes')
      project_id: @model.get('id')
      users: @users
    @notesRegion.show(notesView)

  cookieOpenNotes: ->
    $(document).ready ->
      note_id = $.cookie('note_id')
      if note_id
        $.removeCookie('note_id')
        note = $('#' + note_id)
        note.closest('.project-notes-wrapper').siblings('.js-open-project-notes').click()
        $.scrollTo(note, 'fast')

  onOpenProjectNotes: ->
    @ui.openNotes.hide()
    @ui.closeNotes.show()
    @ui.notesWrapper.show()

  onCloseProjectNotes: ->
    @ui.openNotes.show()
    @ui.closeNotes.hide()
    @ui.notesWrapper.hide()
