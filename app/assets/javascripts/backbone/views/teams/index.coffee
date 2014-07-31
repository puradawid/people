class Hrguru.Views.TeamsIndex extends Marionette.Layout

  el: '#main-container'
  template: JST['teams/index']

  regions:
    buttonRegion: '#buttons-region'
    teamsRegion: '#teams-region'

  initialize: ->
    @teams = new Hrguru.Collections.Teams(gon.teams)
    @users = new Hrguru.Collections.Users(gon.users)
    @roles = new Hrguru.Collections.Roles(gon.roles)
    @render()

  onRender: ->
    @teams_view = new Hrguru.Views.Teams (
      collection: @teams
      users: @users
      roles: @roles
    )
    @teamsRegion.show @teams_view

