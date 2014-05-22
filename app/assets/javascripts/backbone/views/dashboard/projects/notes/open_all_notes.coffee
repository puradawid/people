class Hrguru.Views.Dashboard.OpenAllNotes extends Marionette.ItemView

  template: JST['dashboard/projects/notes/open_all_notes']

  className: 'open-all-notes'

  ui:
    openAllNotesButton:    '.js-open-all-notes'
    closeAllNotesButton:   '.js-close-all-notes'

  triggers:
    'click .js-open-all-notes' : 'open:notes:clicked'
    'click .js-close-all-notes' : 'close:notes:clicked'

  onRender: ->
    @ui.closeAllNotesButton.hide()

  onOpenNotesClicked: ->
    @toggleOpenButton()
    EventAggregator.trigger('open:all:notes', @)

  onCloseNotesClicked: ->
    @toggleOpenButton()
    EventAggregator.trigger('close:all:notes', @)

  toggleOpenButton: ->
    @ui.openAllNotesButton.toggle()
    @ui.closeAllNotesButton.toggle()
