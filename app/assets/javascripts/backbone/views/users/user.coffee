class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()
    @initializeSortableAbilities()

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

  initializeSortableAbilities: ->
    @$('div.selectize-input.items.not-full.has-options').sortable (->),
      axis: 'x'
      tolerance: 'pointer'
      update: ->
        $('select.optional.selectized option').remove()
        _.each $('.ui-sortable.focus .item'), (item)->
          item_value = $(item).attr('data-value')
          $('select.optional.selectized').append $('<option>',
            value: item_value
            selected: 'selected'
          )
    @$( "#sortable" ).disableSelection();


