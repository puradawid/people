class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()
    elTimeline = @$(".timeline")
    @timeline = elTimeline.timeline(gon.events)
    elTimeline.scrollTo(elTimeline[0].scrollWidth, 0)
    @$el.after @timeline

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

