class Hrguru.Views.AvailableUsersCollectionView extends Marionette.CollectionView
  el: ('#available_users')
  tagName: 'tbody'

  itemView: Hrguru.Views.AvailableUsersRow

  events:
    "click .up" : "incressingDirection"
    "click .down" : "decreasingDirection"

  initialize: (@collection) ->
    @on('collection:rendered', H.addUserIndex)

  incressingDirection: (e) ->
    @toggleClass(e.target)
    @collection.sortDirection = 1
    @sort(e.target.dataset.sort, @collection.sortDirection)

  decreasingDirection: (e) ->
    @toggleClass(e.target)
    @collection.sortDirection = 0
    @sort(e.target.dataset.sort, @collection.sortDirection)

  sort: (value = 'availability_time', direction = 1) ->
    @collection.sortUsers(value, direction)
    @render()
    EventAggregator.trigger('users:updateVisibility', @getSelectizeData())

  toggleClass: (target) ->
    @$('.active').removeClass('active')
    $(target).addClass('active')

  getSelectizeData: ->
    data = {}
    _.each $('.selectized'), (element) ->
      data[$(element).attr('name')] = $(element)[0].selectize.items
    data
