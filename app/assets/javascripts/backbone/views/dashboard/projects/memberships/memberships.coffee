class Hrguru.Views.Dashboard.Memberships extends Marionette.CompositeView

  template: JST['dashboard/projects/memberships/memberships']
  completionTemplate: JST['dashboard/projects/memberships/completion']

  itemViewContainer: '.js-project-memberships'
  itemViewOptions: ->
    users: @users
    roles: @roles
    project: @model

  collectionEvents:
    add: 'refreshView'
    remove: 'refreshView'
    sync: 'refreshView'

  initialize: (options) ->
    { @users, @roles, @model } = options
    @refreshSelectizeOptions()
    @listenTo(@model, 'membership:finished', @removeMembership)

  getItemView: (item) ->
    name = switch
      when !item.started() then 'UnstartedMembership'
      else 'Membership'
    Hrguru.Views.Dashboard[name]

  refreshView: ->
    @.render()
    @refreshSelectizeOptions()
    @model.trigger('members:change', @model)

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

  refreshSelectizeOptions: ->
    selected = _.compact(@collection.pluck('user_id'))
    to_select = @users.select (model) -> !(model.get('id') in selected)
    @selectize_options = to_select.map (model) -> model.toJSON()
    if @selectize?
      @selectize.clearOptions()
      @selectize.load (callback) => callback(@selectize_options)

  removeMembership: (item_view) ->
    return unless item_view
    @collection.remove(item_view.model)
    @removeEditPopupView(item_view.model)
    user_name = item_view.user.get('name')
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
