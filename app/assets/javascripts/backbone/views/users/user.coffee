class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'

  events:
    'change #js-user-roles': 'updatePrimaryRole'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()
    @initializeRoles()
    elTimeline = @$('.timeline')
    @timeline = elTimeline.timeline(gon.events)
    elTimeline.scrollTo(elTimeline[0].scrollWidth, 0)
    @$el.after @timeline

  removeFormControlClass: ->
    @$('#js-user-abilities').removeClass('form-control')
    @$('#js-user-roles').removeClass('form-control')

  initializeAbilities: ->
    @$('#js-user-abilities').selectize
      plugins: ['remove_button', 'drag_drop']
      delimiter: ','
      persist: false
      create: (input) ->
        value: input
        text: input

  initializeRoles: ->
    @$('#js-user-roles').selectize
      plugins: ['remove_button', 'drag_drop']
      delimiter: ','
      persist: false
      create: (input) ->
        value: input
        text: input

  updatePrimaryRole: (e) ->
    @checkCurrentPrimary()
    @emptyRoles()

    _.each e.target.options, ((option) ->
      optionModel = new Backbone.Model({value: option.value, text: option.text})
      optionModel.set('selected', 'selected') if option.value is @currentPrimary

      @$('#js-user-primary').append(new Hrguru.Views.
        RoleOption(model: optionModel).render().el)
    ), this

  emptyRoles: ->
    emptyOption = new Backbone.Model({value: '', text: 'no role'})

    @$('#js-user-primary').empty().prepend(new Hrguru.Views.
      RoleOption(model: emptyOption).render().el)

  checkCurrentPrimary: ->
    @currentPrimary = @$('#js-user-primary').children('option:selected').val()
