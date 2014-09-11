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
    @dev_users = @devsOnly()
    @no_team_users = @noTeamUsers()
    @render()

  devsOnly: ->
    roles = @roles
    filtered = @base_users.filter (user) ->
      _role = roles.get(user.get('role_id'))
      role = if _role then _role.get('name') else null
      _.contains(['developer', 'senior', 'junior', 'praktykant', null], role)
    new Hrguru.Collections.Users(filtered)

  noTeamUsers: ->
    filtered = @dev_users.where team_id: null, archived: false
    new Hrguru.Collections.Users(filtered)

  renderModalView: (model) ->
    @modal_view = new Hrguru.Views.ModalView
      team: model
    @modalRegion.show @modal_view

  onRender: ->
    @teams_view = new Hrguru.Views.Teams
      collection: @teams
      users: @dev_users
      roles: @roles

    @buttons_view = new Hrguru.Views.TeamButtons
      teams: @teams
      roles: @roles

    @no_team_view = new Hrguru.Views.NoTeamUsers
      team_users: @dev_users
      collection: @no_team_users
      roles: @roles

    @buttonsRegion.show @buttons_view if H.currentUserIsAdmin()
    @teamsRegion.show @teams_view
    @noTeamRegion.show @no_team_view
