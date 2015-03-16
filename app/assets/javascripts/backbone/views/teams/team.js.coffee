class Hrguru.Views.EmptyLeader extends Backbone.Marionette.ItemView
  template: JST['teams/empty_leader']
  tagName: 'li'

class Hrguru.Views.TeamUser extends Backbone.Marionette.ItemView
  template: JST['teams/team_user']
  tagName: 'li'

  events:
    'click .js-exclude-member'  : 'onMembersExcludeClicked'
    'click .js-promote-leader'  : 'onPromoteLeaderCLicked'

  ui:
    promote:    '.js-promote-leader'
    exclude:    '.js-exclude-member'
    daysCount:  '.js-number-of-days'

  bindings:
    '.js-number-of-days':
      observe: 'team_join_time'
      update: ($el, val, model, options) ->
        val = if val then val else 0
        if val == 0
          days_count = 0
        else
          days_count = Math.floor((new Date() - Date.parse(val)) / 86400000)
        duration = switch
          when 60 > days_count > 30 then "1 month"
          when days_count >= 60 then "#{Math.floor(days_count / 30)} months"
          else "#{days_count} days"
        $el.text("Since: " + duration)

  initialize: (options) ->
    unless @model.get('id')?
      return
    @noUI = options.noUI?
    @role = options.roles.findWhere id: @model.get('role_id')
    @role_name = if @role then @role.get('name') else 'no role'
    @billable = if @role.get('billable') then 'billable'
    @listenTo(@model, 'change', @render)

  updateVisibility: ->
    if @noUI
      if @model.get('team_id') is null then @$el.show() else @$el.hide()
      @hideUI()
    if @model.get('leader_team_id')?
      @$el.hide()
    if @options.leader_display?
      @$el.show()

  onRender: ->
    @updateVisibility()
    @stickit()
    @ui.promote.tooltip()

  hideUI: ->
    @ui.promote.hide()
    @ui.exclude.hide()
    @ui.daysCount.hide()

  serializeData: ->
    model: @model.toJSON()
    role_name: @role_name
    billable: @billable

  onMembersExcludeClicked: =>
    @trigger('exclude', @model)

  onPromoteLeaderCLicked: =>
    @trigger('promote', @model)

class Hrguru.Views.TeamMembers extends Backbone.Marionette.CollectionView
  itemView: Hrguru.Views.TeamUser
  tagName: 'ul'
  className: 'team-members'

  events:
    'click .js-add-member': 'toggleMemberForm'

  initialize: (options) ->
    @roles = options.roles
    @users = options.users
    @refreshTeamUsers()
    @listenTo(@, 'itemview:exclude', @excludeMember)
    @listenTo(@, 'itemview:promote', @promoteLeader)

  onRender: ->
    @leader = _.find @collection.models, (leader) =>
      leader.get('leader_team_id') is @model.id
    @trigger('leader_set', @children.findByModel(@leader)) if @leader?

  itemViewOptions: ->
    roles: @roles

  excludeMember: (member_view) =>
    member_view.model.save team_id: null, leader_team_id: null,
      wait: true
      success: @memberExcluded
      error: @memberError

  memberExcluded: (member) =>
    Messenger().success("We successfully excluded #{member.get('name')} from #{@model.get('name')}!")
    @refreshTeamUsers()
    @updateNoTeamUsers(member)
    @trigger('leader_set', @children.findByModel(member)) if member._previousAttributes.leader_team_id?

  memberError: (model, xhr) ->
    Messenger().error(xhr.responseJSON.errors)

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
    @trigger('leader_set', @children.findByModel(leader))

  refreshTeamUsers: ->
    @collection = _.clone @users
    @collection.models =  _.filter @collection.models, (user) =>
      user.get('team_id') is @model.id
    EventAggregator.trigger('selectize:refreshOptions')
    @render()

  updateNoTeamUsers: (member) ->
    EventAggregator.trigger('update:noTeamUsers', member)


class Hrguru.Views.TeamLayout extends Backbone.Marionette.Layout
  template: JST['teams/team_layout']
  completionTemplate: JST['dashboard/projects/memberships/completion']
  tagName: 'li'
  className: 'col-md-3'

  regions:
    leaderRegion:   '#leader-region'
    membersRegion:  '#members-region'

  ui:
    form: '.js-team-member-new'
    name: '.team-name'
    billableCounter: '.devs'
    nonbillableCounter: '.jnrs'

  events:
    'click .js-add-member': 'toggleMemberForm'
    'click .js-edit-team' : -> EventAggregator.trigger('modal:edit:team', @model)

  modelEvents:
    'change:name' : 'render'

  initialize: (options) ->
    @users = options.users
    @roles = options.roles
    @leader = null
    @membersView = new Hrguru.Views.TeamMembers users: @users, roles: @roles, model: @model
    @membersView.on('leader_set', @setLeader)

  onRender: ->
    @initializeSelectize()
    @refreshSelectizeOptions()
    @renderMembersRegion()
    @renderLeaderRegion()
    @initializeTooltip()

  countMembers: ->
    team_members = _.filter @users.models, (user) =>
      user.get('team_id') is @model.id
    @setCounter(team_members, true, @ui.billableCounter)
    @setCounter(team_members, false, @ui.nonbillableCounter)

  setCounter: (team_members, billable, $counter) ->
    ids = @roles
      .filter (role) -> role.get('billable') is billable
      .map (role) -> role.get('id')
    filtered = _.filter team_members, (user) -> user.get('role_id') in ids
    $counter.text(filtered.length)

  highlight: (class_name) ->
    leader_cell = $(@leaderRegion.$el)
    leader_cell.removeClass().addClass(class_name)

  renderMembersRegion: ->
    @membersRegion.show(@membersView)

  renderLeaderRegion:() =>
    if @leaderView?
      @leaderView.options.leader_display = true
      @highlight('team-members filled')
      @leaderRegion.show @leaderView
    else
      @leaderRegion.show(new Hrguru.Views.EmptyLeader)
      @highlight('team-members empty')

  setLeader: (leader) =>
    @leaderView = leader
    @renderLeaderRegion()

  serializeData: ->
    model: @model.toJSON()

  addMember: (value, item) =>
    member = _.find @users.models, (u) ->
      u.get('id') is value
    member.save team_id: @model.id,
      wait: true
      success: @memberAdded
      error: @memberError
    @selectize.clear()

  memberAdded: (member) =>
    Messenger().success("We successfully added #{member.get('name')} to #{@model.get('name')}!")
    @membersView.refreshTeamUsers()
    @refreshSelectizeOptions()

  memberError: (model, xhr) ->
    Messenger().error(xhr.responseJSON.errors)

  refreshSelectizeOptions: ->
    @countMembers()
    selected = _.compact(@membersView.collection.pluck('id'))
    to_select = @users.select (model) -> !(model.get('team_id')?)
    @selectize_options = to_select.map (model) -> model.toJSON()
    if @selectize?
      @selectize.clearOptions()
      @selectize.load (callback) => callback(@selectize_options)

  initializeSelectize: =>
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
    @listenTo(EventAggregator, 'selectize:refreshOptions', @refreshSelectizeOptions)

  initializeTooltip: ->
    if @ui.name.attr('title').length > 9 then @ui.name.tooltip()

class Hrguru.Views.Teams extends Backbone.Marionette.CompositeView
  template: JST['teams/teams']
  itemView: Hrguru.Views.TeamLayout
  emptyView: Hrguru.Views.TeamsEmpty
  itemViewContainer: '#teams-body'
  className: 'table table-hover'

  itemViewOptions: ->
    users: @users
    roles: @roles
    teams: @collection

  initialize: (options) ->
    @users = options.users
    @roles = options.roles

class Hrguru.Views.NoTeamUsers extends Backbone.Marionette.CompositeView
  template: JST['teams/no_team_users']
  itemView: Hrguru.Views.TeamUser
  itemViewContainer: '#users-body'

  ui:
    usersTable: '.js-users-table'

  events:
    'click .show-users' : 'toggleUserTable'

  initialize: (options) ->
    @team_users = options.team_users
    @no_team_users = options.collection
    @roles = options.roles
    @listenTo(EventAggregator, 'update:noTeamUsers', @updateNoTeamUsers)

  itemViewOptions: ->
    roles: @roles
    collection: @no_team_users
    tagName: 'div'
    className: 'col-md-2'
    noUI: true

  onRender: ->
    @ui.usersTable.hide()

  toggleUserTable: ->
    @ui.usersTable.toggle()

  updateNoTeamUsers: (member) ->
    mem = @team_users.find (m) ->
      m is member
    @collection.add mem
