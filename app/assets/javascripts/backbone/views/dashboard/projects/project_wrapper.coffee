class Hrguru.Views.Dashboard.ProjectWrapper extends Marionette.Layout

  template: JST['dashboard/projects/project_wrapper']
  className: 'project'

  ui:
    billable_ratio: '.billable_ratio'
    archive: '.archive'
    time: '.time'
    timeline_show: '.js-timeline-show'
    timeline_hide: '.js-timeline-hide'

  regions:
    membershipsRegion: '.js-memberships-region'
    notesRegion:       '.js-notes-region'

  events:
    'click .archive'   : 'archiving'
    'click .unarchive' : 'unarchiving'
    'click .js-timeline-show' : 'toggleTimeline'
    'click .js-timeline-hide' : 'toggleTimeline'

  initialize: (options) ->
    { @users, @roles, @model, @memberships } = options
    @listenTo(@model, 'members:change', @updateBillableInfo)
    @listenTo(EventAggregator, 'projects:toggleVisibility', @toggleVisibility)
    @listenTo(EventAggregator, 'projects:toggleByType', @toggleByType)
    @listenTo(EventAggregator, 'project:highlightEnding', @highlightEnding)

  onRender: ->
    @renderNotesRegion()
    @renderMembershipsRegion()
    @renderTimelineRegion()
    @updateBillableInfo()

  renderTimelineRegion: ->
    @ui.timeline_hide.css('color', 'red')
    @ui.timeline_hide.hide()

  renderNotesRegion: ->
    notesLayout = new Hrguru.Views.Dashboard.NotesLayout
      model: @model
      users: @users
    @notesRegion.show(notesLayout)

  renderMembershipsRegion: ->
    collectMemberships = @model.get('memberships')
    membershipsLayout = new Hrguru.Views.Dashboard.Memberships
      collection: collectMemberships
      model: @model
      roles: @roles
      users: @users
    @membershipsRegion.show(membershipsLayout)

  highlightEnding: (state) ->
    return unless @showEndingTime()
    leftDays = 30
    leftDays >= @model.daysToEnd()
    @$el.toggleClass("left", state)
    @ui.time.toggleClass('hidden', !state)

  showEndingTime: ->
    @model.daysToEnd()? && @model.isActive()

  updateBillableInfo: ->
    collection = @model.get('memberships')
    billable_counter = _.countBy(collection.models, (currentObject) ->
      if currentObject.started()
        currentObject.get('billable'))
    billable = billable_counter.true || 0
    not_billable = billable_counter.false || 0
    @ui.billable_ratio.html(billable + "/" + not_billable)

  toggleVisibility: (ids) ->
    show = ids.length == 0 || @model.get('id') in ids
    @$el.toggleClass('hide', !show)

  toggleByType: (data) ->
    if @model.type() == data.type
      @$el.show()
    else
      @$el.hide()

  archiving: ->
    @updateProjectArchive(true, 'archived')

  unarchiving: ->
    @updateProjectArchive(false, 'unarchived')

  updateProjectArchive: (value, message) ->
    return unless confirm("Are you sure?")
    @model.save({ archived: value },
      patch: true
      success: (model, response, options) =>
        if value
          _.each @model.get('memberships').unFinished().models, (membership) ->
            membership.trigger('membership:ended')
        Messenger().success("Project has been #{message}")
        @$el.toggleClass('archived', value)
        @$el.hide()
      error: (model, xhr) =>
        Messenger().error(xhr.responseJSON.errors)
    )

  toggleTimeline: ->
    @ui.timeline_show.toggle()
    @ui.timeline_hide.toggle()

