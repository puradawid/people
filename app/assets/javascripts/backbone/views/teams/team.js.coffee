class Hrguru.Views.TeamUser extends Backbone.Marionette.ItemView
  template: JST['teams/team_user']
  tagName: 'td'

  events:
    'click .js-exclude-member' : 'onMembersExcludeClicked'
    'click .js-promote-leader': 'onPromoteLeaderCLicked'

  ui:
    promote: '.js-promote-leader'
    exclude: '.js-exclude-member'

  initialize: (options) ->
    @noUI = options.noUI?
    @role = _.find(options.roles.models, (role) =>
      role.id is @model.get('role_id')
    )
    @role_name = @role.get('name')
    @$el.addClass('success') if @model.get('leader_team_id')?
    @listenTo(@model, 'change', @updateVisibility)

  updateVisibility: ->
    if @noUI
      if @model.get('team_id') is null then @$el.show() else @$el.hide()

  onRender: ->
    @hideUI() if @noUI
    @updateVisibility()

  hideUI: ->
    @ui.promote.hide()
    @ui.exclude.hide()

  serializeData: ->
    model: @model.toJSON()
    role_name: @role_name

  onMembersExcludeClicked: =>
    @trigger('exclude', @model)

  onPromoteLeaderCLicked: =>
    @trigger('promote', @model)

class Hrguru.Views.Team extends Backbone.Marionette.CompositeView
  itemView: Hrguru.Views.TeamUser
  template: JST['teams/team']
  completionTemplate: JST['dashboard/projects/memberships/completion']
  tagName: 'tr'

  ui:
    form: '.js-team-member-new'

  events:
    'click .js-add-member': 'toggleMemberForm'

  initialize: (options) ->
    @users = options.users
    @roles = options.roles
    @refreshTeamUsers()

    @listenTo(@, 'itemview:exclude', @excludeMember)
    @listenTo(@, 'itemview:promote', @promoteLeader)

  itemViewOptions: ->
    roles: @roles

  onRender: ->
    @ui.form.hide()
    @refreshSelectizeOptions()
    selectize = @$('.js-team-member-new input').selectize
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      options: @selectize_options
      onItemAdd: (value, item) => @addMember(value, item)
      render:
        option: (item, escape) => @completionTemplate(item)
    @selectize = selectize[0].selectize

  toggleMemberForm: ->
    @ui.form.fadeToggle('fast')

  addMember: (value, item) =>
    member = _.find @users.models, (u) ->
      u.get('id') is value

    member.save team_id: @model.id,
      wait: true
      success: @memberAdded
      error: @memberError
    @selectize.clear()
    @ui.form.fadeToggle('slow')

  memberAdded: (member) =>
    Messenger().success("We successfully added #{member.get('name')} to #{@model.get('name')}!")
    @refreshTeamUsers()
    @render()

  memberError: (model, xhr) ->
    Messenger().error(xhr.responseJSON.errors)

  excludeMember: (member) =>
    member.model.save team_id: null, leader_team_id: null,
      wait: true
      success: @memberExluded
      error: @memberError

  memberExluded: (member) =>
    Messenger().success("We successfully exluded #{member.get('name')} from #{@model.get('name')}!")
    @refreshTeamUsers()
    @render()

  promoteLeader: (leader) =>
    old_leader = _.find @users.models, (u) =>
      u.get('leader_team_id') is @model.id

    if old_leader?
      old_leader.save leader_team_id: null,
        wait: true
        success: () => @saveNewLeader(leader)
        error: @memberError
    else
      @saveNewLeader(leader)

  saveNewLeader: (leader) =>
    leader.model.save leader_team_id: @model.id,
      wait: true
      success: @leaderPromoted
      error: @memberError

  leaderPromoted: (leader) =>
    Messenger().success("We successfully promoted #{leader.get('name')} to the leader of #{@model.get('name')}!")
    @refreshTeamUsers()
    @render()

  refreshTeamUsers: ->
    @collection = _.clone @users
    @collection.models =  _.filter @collection.models, (user) =>
      user.get('team_id') is @model.id
    # @collection.sortUsers('leader_team_id')

  refreshSelectizeOptions: ->
    selected = _.compact(@collection.pluck('id'))
    to_select = @users.select (model) -> !(model.get('team_id')?)
    @selectize_options = to_select.map (model) -> model.toJSON()
    if @selectize?
      @selectize.clearOptions()
      @selectize.load (callback) => callback(@selectize_options)

class Hrguru.Views.Teams extends Backbone.Marionette.CompositeView
  template: JST['teams/teams']
  itemView: Hrguru.Views.Team
  emptyView: Hrguru.Views.TeamsEmpty
  itemViewContainer: '#teams-body'
  className: 'table table-striped table-hover'

  itemViewOptions: ->
    users: @users
    roles: @roles

  initialize: (options) ->
    @users = options.users
    @roles = options.roles
