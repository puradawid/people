class Hrguru.Views.TeamsIndex extends Marionette.Layout

  el: '#main-container'
  template: JST['teams/index']

  regions:
    buttonsRegion:  '#buttons-region'
    teamsRegion:    '#teams-region'
    noTeamRegion:   '#no-team-region'

  initialize: ->
    @teams = new Hrguru.Collections.Teams(gon.teams)
    @users = new Hrguru.Collections.Users(gon.users)
    @roles = new Hrguru.Collections.Roles(gon.roles)
    @render()

  onRender: ->
    @teams_view = new Hrguru.Views.Teams
      collection: @teams
      users: @users
      roles: @roles

    @buttons_view = new Hrguru.Views.TeamButtons
      collection: @users
      teams: @teams
      roles: @roles

    @no_team_view = new Hrguru.Views.NoTeamUsers
    @buttonsRegion.show @buttons_view if H.currentUserIsAdmin()
    @teamsRegion.show @teams_view
    @noTeamRegion.show @no_team_view
