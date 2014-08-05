class Hrguru.Views.AvailableUsersIndex extends Marionette.View

  el: '#main-container'

  initialize: ->
    $("*[rel=tooltip]").tooltip()
    $('table').tablesorter()
