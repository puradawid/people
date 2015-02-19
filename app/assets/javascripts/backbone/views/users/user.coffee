class Hrguru.Views.UsersShow extends Backbone.View
  el: '#user'
  ui:
    select2_roles: '#user_role_ids'

  initialize: ->
    @removeFormControlClass()
    @initializeAbilities()
    @initializeRoles()
    elTimeline = @$('.timeline')
    @timeline = elTimeline.timeline(gon.events)
    elTimeline.scrollTo(elTimeline[0].scrollWidth, 0)
    @$el.after @timeline
    @bindUIElements()
    @rolesSelect2 @ui.select2_roles

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

  @include 'Select2', 'RolesSelect2'
