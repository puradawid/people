class Hrguru.Views.AvailableUsersIndex extends Marionette.View

  el: '#main-container'

  initialize: ->
    $("*[rel=tooltip]").tooltip()
    @setSorterParser()
    $('table').tablesorter headers:
      3:
        sorter: 'available'

  setSorterParser: ->
    $.tablesorter.addParser
      id: 'available'
      is: (s) ->
        false
      format: (s) ->
        s.replace(/since now/, '0')
      type: 'date'
