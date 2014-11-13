class Hrguru.Views.TeamsIndex extends Marionette.Layout

  el: '#main-container'
  template: JST['teams/index']

  regions:
    buttonsRegion:  '#buttons-region'
    teamsRegion:    '#teams-region'
    noTeamRegion:   '#no-team-region'
    modalRegion:    '#modal-region'

  initialize: ->
    @listenTo(EventAggregator, 'modal:edit:team', @renderModalView)
    @teams = new Hrguru.Collections.Teams(gon.teams)
    @roles = new Hrguru.Collections.Roles(gon.roles)
    @base_users = new Hrguru.Collections.Users(gon.users)
    @visible_team_users = @visibleOnly()
    @no_team_users = @noTeamUsers()
    @render()

  visibleOnly: ->
    roles = @roles
    visibleRoles = @roles.where show_in_team:true
    filtered = @base_users.where(archived:false).filter (user) ->
      role = roles.get(user.get('role_id'))
      _.contains(visibleRoles, role)
    new Hrguru.Collections.Users(filtered)

  noTeamUsers: ->
    filtered = @visible_team_users.where team_id:null, archived:false
    new Hrguru.Collections.Users(filtered)

  renderModalView: (model) ->
    @modal_view = new Hrguru.Views.ModalView
      team: model
    @modalRegion.show @modal_view

  onRender: ->
    @teams_view = new Hrguru.Views.Teams
      collection: @teams
      users: @visible_team_users
      roles: @roles

    @buttons_view = new Hrguru.Views.TeamButtons
      teams: @teams
      roles: @roles

    @no_team_view = new Hrguru.Views.NoTeamUsers
      team_users: @visible_team_users
      collection: @no_team_users
      roles: @roles

    @buttonsRegion.show @buttons_view if H.currentUserIsAdmin()
    @teamsRegion.show @teams_view
    @noTeamRegion.show @no_team_view
