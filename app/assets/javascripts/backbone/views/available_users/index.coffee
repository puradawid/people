class Hrguru.Views.AvailableUsersIndex extends Backbone.View
  el: '#main-container'

  initialize: ->
    @createCollections()
    @createViews()
    @defaultSorting()

  createCollections: ->
    @users = new Hrguru.Collections.Users(gon.users)
    @active_users = @users.active()
    @roles = new Hrguru.Collections.Roles(gon.roles)

  createViews: ->
    @filters_view = new Hrguru.Views.AvailableUsersFilters(
      gon.availability_time, gon.abilities, @roles
    )
    @filters_view.render()
    @tbodyView = new Hrguru.Views.AvailableUsersCollectionView(@users)
    @tbodyView.render()

  defaultSorting: ->
    $('.default').click()
