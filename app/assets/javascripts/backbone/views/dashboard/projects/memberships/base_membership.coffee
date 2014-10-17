class Hrguru.Views.Dashboard.BaseMembership extends Marionette.ItemView

  initialize: ->
    @listenTo(EventAggregator, 'roles:toggleVisibility', @toggleVisibility)
    @role = @options.roles.get(@model.get('role_id'))
    @user = @options.users.get(@model.get('user_id'))

  serializeData: ->
    $.extend(super, { user: @user.toJSON(), role: @role.toJSON() })

  toggleVisibility: (ids) ->
    show = ids.length == 0 || @model.get('role_id') in ids
    @$el.toggleClass('hide', !show)
