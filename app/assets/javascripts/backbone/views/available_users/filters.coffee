class Hrguru.Views.AvailableUsersFilters extends Marionette.View
  el: '#filters'

  initialize: (@availability_time) ->
    @initializeVariables()

  initializeVariables: ->
    @selectize =
      availability_time: []

  render: ->
    @initializeAvailabilityTimeFilter()

  initializeAvailabilityTimeFilter: ->
    availability_time_selectize = @$('select[name=availability_time]').selectize
      create: false
      valueField: 'value'
      sortField: 'value'
      labelField: 'text'
      options: @availability_time
    availability_time_selectize.change @, @updateSelectizeAvailability
    @selectize.availability_time = availability_time_selectize[0].selectize.items[0]

  updateSelectizeAvailability: (e) =>
    @selectize.availability_time = $(e.target).first().val()
    @filterUsers()

  filterUsers: =>
    EventAggregator.trigger('users:updateVisibility', @selectize)
    H.addUserIndex()
