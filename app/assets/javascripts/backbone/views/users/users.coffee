class Hrguru.Views.UsersCollectionView extends Marionette.CollectionView
  el: ('#users')
  tagName: 'tbody'

  itemView: Hrguru.Views.UsersRow

  events:
    "click .sort .up" : "incressingDirection"
    "click .sort .down" : "decreasingDirection"

  initialize: (@collection) ->
    @listenTo(EventAggregator, 'user:sortAndHighlightEnding', @sortEnding)
    @listenTo(EventAggregator, 'user:sortBeforePotential', @sortByPotential)
    @on('collection:rendered', H.addUserIndex)

  incressingDirection: (e) ->
    @toggleClass(e.target)
    @collection.sortDirection = 1
    @sort(e.target.dataset.sort)

  decreasingDirection: (e) ->
    @toggleClass(e.target)
    @collection.sortDirection = 0
    @sort(e.target.dataset.sort)

  sort: (value) ->
    @collection.sortUsers(value)
    @render()
    @$('.icons a').tooltip()
    H.initTooltips()

  toggleClass: (target) ->
    @$('.active').removeClass('active')
    $(target).addClass('active')

  sortEnding: (flag) ->
    if flag then @sort('daysToEndMembership') else @sort('name')
    EventAggregator.trigger 'UsersRow:toggleEnding', flag

  sortByPotential: (state) ->
    if state then @sort('daysToEndMembership') else @sort('name')
    EventAggregator.trigger 'UsersRow:showOnlyIfPotential', state
