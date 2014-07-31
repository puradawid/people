class Hrguru.Views.TeamUser extends Backbone.Marionette.ItemView
  template: JST['teams/team_user']
  tagName: 'td'

  initialize: (options) ->
    @role = _.find(options.roles.models, (role) =>
      role.id is @model.get('role_id')
    )
    @role_name = @role.get('name')

  serializeData: ->
    model: @model.toJSON()
    role_name: @role_name

class Hrguru.Views.Team extends Backbone.Marionette.CompositeView
  itemView: Hrguru.Views.TeamUser
  template: JST['teams/team']
  tagName: 'tr'

  initialize: (options) ->
    @collection = options.users
    @collection.models =  _.filter @collection.models, (user) =>
      user.get('team_id') is @model.id
    @roles = options.roles

  itemViewOptions: ->
    roles: @roles

class Hrguru.Views.Teams extends Backbone.Marionette.CompositeView
  template: JST['teams/teams']
  itemView: Hrguru.Views.Team
  itemViewContainer: '#teams-body'
  className: 'table table-striped table-hover'

  itemViewOptions: ->
    users: @users
    roles: @roles

  ui:
    addMember: '.js-add-member'
    excludeMember: '.js-exlude-member'

  events:
    'click .js-add-member' : 'addMember'
    'click td .js-exclude-member' : 'excludeMember'

  initialize: (options) ->
    @users = options.users
    @roles = options.roles
