class Hrguru.Views.Dashboard.Memberships extends Marionette.CompositeView

  template: JST['dashboard/projects/memberships/memberships']
  completionTemplate: JST['dashboard/projects/memberships/completion']

  itemViewContainer: '.js-project-memberships'
  itemViewOptions: ->
    users: @users
    roles: @roles
    project: @model

  initialize: (options) ->
    { @users, @roles, @model } = options

  getItemView: (item) ->
    name = unless item.started() then 'UnstartedMembership' else 'Membership'
    Hrguru.Views.Dashboard[name]
