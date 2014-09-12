class Hrguru.Views.Dashboard.MembershipsLayout extends Marionette.Layout
  template: JST['dashboard/projects/memberships/layout']

  regions:
    billableRegion: '.billable'
    nonBillableRegion: '.non-billable'

  collectionEvents:
    add: 'refreshView'
    remove: 'refreshView'
    sync: 'refreshView'

  initialize: (options) ->
    { @users, @roles, @model, @collection } = options
    [@billable, @nonBillable] = @getUsers()
    @refreshSelectizeOptions()
    @listenTo(@model, 'membership:finished', @removeMembership)
    @listenTo(EventAggregator, 'membership:updated:billable', @updateCollections)

  getUsers: ->
    roles = @roles.where(billable: true).map (role) -> role.get('id')
    billable = new Hrguru.Collections.Memberships
    non_billable = new Hrguru.Collections.Memberships
    @collection.each (user) ->
      if _.contains(roles, user.get('role_id')) || user.get('billable')
        billable.add(user)
      else
        non_billable.add(user)
    [billable, non_billable]

  refreshView: ->
    @.render()
    @refreshSelectizeOptions()
    @model.trigger('members:change', @model)

  updateCollections: (membership) ->
    if membership.get('billable')
      @billable.add(membership)
      @nonBillable.remove(membership)
    else
      @nonBillable.add(membership)
      @billable.remove(membership)

  removeFromCollections: (view) ->
    group = if view.model.get('billable') then @billable else @nonBillable
    group.remove(view.model)

  addToCollections: (membership) ->
    group = if membership.get('billable') then @billable else @nonBillable
    group.add(membership)

  onRender: ->
    return unless H.currentUserIsAdmin()
    selectize = @$('.new-membership input').selectize
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      options: @selectize_options
      onItemAdd: (value, item) => @newMembership(value, item)
    @selectize = selectize[0].selectize
    @fillEditPopups()
    @renderBillableRegion()
    @renderNonBillableRegion()

  refreshSelectizeOptions: ->
    selected = _.compact(@collection.pluck('user_id'))
    to_select = @users.select (model) -> !(model.get('id') in selected)
    @selectize_options = to_select.map (model) -> model.toJSON()
    if @selectize?
      @selectize.clearOptions()
      @selectize.load (callback) => callback(@selectize_options)

  renderMembershipsRegion: (collection) ->
    new Hrguru.Views.Dashboard.Memberships
      users: @users
      roles: @roles
      model: @model
      collection: collection

  renderBillableRegion: ->
    region = @renderMembershipsRegion(@billable)
    @billableRegion.show(region)

  renderNonBillableRegion: ->
    region = @renderMembershipsRegion(@nonBillable)
    @nonBillableRegion.show(region)

  removeMembership: (view) ->
    return unless view
    @removeFromCollections(view)
    @collection.remove(view.model)
    @removeEditPopupView(view.model)
    user_name = view.user.get('name')
    project_name = @model.get('name')
    Messenger().success("#{user_name} has been removed from #{project_name}")

  newMembership: (value, item) ->
    starts_at = H.currentTime().format()
    role = @users.get(value).get('role_id')
    billable = @roles.get(role).get('billable')
    attributes = { project_id: @model.id, role_id: role, user_id: value, starts_at: starts_at, billable: billable }
    @collection.create attributes,
      wait: true
      success: (membership) => @membershipCreated(membership)
      error: (membership, request) => @membershipError(membership, request)

  membershipCreated: (membership) ->
    @addToCollections(membership)
    @selectize.clear()
    user_name = @users.get(membership.get('user_id')).get('name')
    project_name = @model.get('name')
    @addEditPopupView(membership)
    Messenger().success("#{user_name} has been added to #{project_name}")

  membershipError: (membership, request) ->
    @selectize.clear()
    [ error_massage ] = request.responseJSON.errors.project
    Messenger().error(error_massage)


  fillEditPopups: ->
    @collection.each (membership) =>
      @addEditPopupView(membership)

  addEditPopupView: (membership) ->
    view = new Hrguru.Views.Dashboard.EditMembershipPopup
      model: membership
    $('#edit-membership-popups').append(view.render().$el)

  removeEditPopupView: (membership) ->
    $('#edit-membership-popups').find("##{membership.id}").remove()
