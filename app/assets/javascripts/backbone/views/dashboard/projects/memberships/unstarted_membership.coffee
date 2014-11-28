class Hrguru.Views.Dashboard.UnstartedMembership extends Hrguru.Views.Dashboard.BaseMembership

  className: 'membership unstarted invisible'
  template: JST['dashboard/projects/memberships/unstarted_membership']

  initialize: ->
    super()
    @user = @options.users.get(@model.get('user_id'))
    @listenTo(EventAggregator, 'memberships:showNext', @showNext)
    @hidden_by_next = true
    @hidden_by_role = false
    @listenTo(EventAggregator, 'memberships:highlightNotBillable', @highlightNotBillable)

  showNext: (state) ->
    @hidden_by_next = !state
    @highlightStarting(state)
    @$el.toggleClass('invisible', @hidden_by_next) unless @hidden_by_role

  highlightStarting: (state)->
    start = _.find [1, 7, 14, 30], (day) => day >= @model.daysToStart()
    @$el.addClass("start-#{start}", state) if start?

  toggleVisibility: (ids) ->
    @hidden_by_role = ids.length > 0 && !(@model.get('role_id') in ids)
    @$el.toggleClass('invisible', @hidden_by_role) unless @hidden_by_next

  highlightNotBillable: (state) ->
    return unless @showNotBillable()
    @$('span.icon').toggleClass("not-billable glyphicon glyphicon-exclamation-sign", state)

  showNotBillable: ->
    @model.hasTechnicalRole(@role) && !@model.isBillable()
