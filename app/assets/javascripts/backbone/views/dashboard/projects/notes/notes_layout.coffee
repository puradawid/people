class Hrguru.Views.Dashboard.NotesLayout extends Marionette.Layout

  template: JST['dashboard/projects/notes/layout']

  regions:
    notesRegion:  '.js-project-notes-region'

  ui:
    notesWrapper: '.js-project-notes-wrapper'
    openNotes:    '.js-open-project-notes'
    closeNotes:   '.js-close-project-notes'

  initialize: (options) ->
    { @users, @model } = options
    @listenTo(EventAggregator, 'open:all:notes', @onOpenProjectNotes)
    @listenTo(EventAggregator, 'close:all:notes', @onCloseProjectNotes)
    @listenToOnce(EventAggregator, 'cookie:open:notes', @cookieOpenNotes)
    @listenTo(@model, 'notes:toggle', -> @ui.notesWrapper.toggle())

  onRender: ->
    @ui.notesWrapper.hide()
    @ui.closeNotes.hide()
    notesView = new Hrguru.Views.Dashboard.Notes
      collection: @model.get('notes')
      project_id: @model.get('id')
      users: @users
    @notesRegion.show(notesView)

  cookieOpenNotes: ->
    $ ->
      note_id = $.cookie('note_id')
      if note_id
        $.removeCookie('note_id')
        note = $('#' + note_id)
        note.closest('.project-notes-wrapper').siblings('.js-open-project-notes').click()
        $.scrollTo(note, 'fast')

  onOpenProjectNotes: ->
    @ui.notesWrapper.show()

  onCloseProjectNotes: ->
    @ui.notesWrapper.hide()
