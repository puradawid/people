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

  initialize: ->
    @listenTo(EventAggregator, 'open:all:notes', @onOpenProjectNotes)
    @listenTo(EventAggregator, 'close:all:notes', @onCloseProjectNotes)

  onRender: ->
    @ui.notesWrapper.hide()
    @ui.closeNotes.hide()
    notesView = new Hrguru.Views.Dashboard.Notes
      collection: @model.get('notes')
      project_id: @model.get('id')
    @notesRegion.show(notesView)

  onOpenProjectNotes: ->
    @ui.openNotes.hide()
    @ui.closeNotes.show()
    @ui.notesWrapper.show()

  onCloseProjectNotes: ->
    @ui.openNotes.show()
    @ui.closeNotes.hide()
    @ui.notesWrapper.hide()
