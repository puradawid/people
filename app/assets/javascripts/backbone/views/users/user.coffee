class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()

  removeFormControlClass: ->
    @$('#user_abilities').removeClass('form-control')

  initializeAbilities: ->
    @$('#user_abilities').selectize
      plugins: ['remove_button']
      delimiter: ','
      persist: false
      create: (input) ->
        value: input
        text: input
