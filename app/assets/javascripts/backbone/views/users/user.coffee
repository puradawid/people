class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()
    @initializeSortableAbilities()

  removeFormControlClass: ->
    @$('#js-user_abilities').removeClass('form-control')

  initializeAbilities: ->
    @$('#js-user_abilities').selectize
      plugins: ['remove_button', 'drag_drop']
      delimiter: ','
      persist: false
      create: (input) ->
        value: input
        text: input