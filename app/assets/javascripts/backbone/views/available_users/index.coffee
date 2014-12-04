class Hrguru.Views.AvailableUsersIndex extends Marionette.View

  el: '#main-container'

  initialize: ->
    $("*[rel=tooltip]").tooltip()
    @setSorterParser()
    $('table').tablesorter headers:
      3:
        sorter: 'available'
    @setDevsInProjectFormHandler()
    @setUserNotesModalHandlers()

  setSorterParser: ->
    $.tablesorter.addParser
      id: 'available'
      is: (s) ->
        false
      format: (s) ->
        s.replace(/since now/, '0')
      type: 'date'

  setDevsInProjectFormHandler: ->
    $form = $('#show-devs-in-project')
    $form.find('select').change (e) ->
      if $(e.target).val() == '0'
        window.location = Routes.available_users_path()
      else
        $form.submit()

  setUserNotesModalHandlers: ->
    $('a.user-notes').click (e) ->
      e.preventDefault()
      user_notes = e.target.getAttribute('data-user-notes')
      $('.user-notes-content').text(user_notes)
