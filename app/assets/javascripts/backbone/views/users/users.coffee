class Hrguru.Views.UsersCollectionView extends Marionette.CollectionView
  el: ('#users')
  tagName: 'tbody'

  itemView: Hrguru.Views.UsersRow

  events:
    "click .sort .up" : "incressingDirection"
    "click .sort .down" : "decreasingDirection"

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

  sort: (value = 'name', direction = 1) ->
    @collection.sortUsers(value, direction)
    @render()

  toggleClass: (target) ->
    @$('.active').removeClass('active')
    $(target).addClass('active')

  sortEnding: (flag) ->
    EventAggregator.trigger 'UsersRow:toggleEnding', flag

  sortByPotential: (state) ->
    EventAggregator.trigger 'UsersRow:showOnlyIfPotential', state
