class Hrguru.Views.Dashboard.Membership extends Hrguru.Views.Dashboard.BaseMembership

  className: 'membership'
  template: JST['dashboard/projects/memberships/membership']

  events:
    'click .remove' : 'finishMembershipConfirm'
    'click .edit' : 'editMembership'

  initialize: ->
    super()
    @project = @options.project
    @user = @options.users.get(@model.get('user_id'))
    @listenTo(EventAggregator, 'memberships:highlightEnding', @highlightEnding)
    @listenTo(EventAggregator, 'memberships:highlightNotBillable', @highlightNotBillable)
    @listenTo @model, 'membership:ended', @finishMembership
    $("##{@model.get('id')}").modal

  onRender: ->
    @project.trigger('projects:rendered', @)

  serializeData: ->
    $.extend(super, { show_time: @showEndingTime(), color: @roleColor() })

  editMembership: (event) ->
    $("##{@model.get('id')}").modal('show')

  finishMembershipConfirm: (event) ->
    return unless confirm("Are you sure?")
    @finishMembership()

  finishMembership: (event) =>
    if !@project.attributes.potential
      ends_at = H.currentTime().format()
      @model.save(
        { ends_at: ends_at }
        {
          patch: true
          success: @finishedMembership
          error: @onMembershipError
        }
      )
    else
      @model.destroy {success: @finishedMembership, error: @onMembershipError}

  finishedMembership: =>
    @close()
    @project.trigger('membership:finished', @)

  onMembershipError: (membership, request) =>
    error_massage = request.responseJSON.errors.project[0]
    Messenger().error(error_massage)

  highlightEnding: (state) ->
    return unless @showEndingTime()
    left = _.find [1, 7, 14, 30], (day) => day >= @model.daysToEnd()
    @$el.toggleClass("left-#{left}", state) if left?

  showEndingTime: ->
    @model.started() && @model.hasEndDate()

  highlightNotBillable: (state) ->
    return unless @showNotBillable()
    @$('span.icon').toggleClass("not-billable glyphicon glyphicon-exclamation-sign", state)

  showNotBillable: ->
    @model.hasTechnicalRole(@role) && !@model.isBillable()

  roleColor: ->
    @role.get('color')
