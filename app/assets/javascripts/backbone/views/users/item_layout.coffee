class Hrguru.Views.UsersRow extends Backbone.Marionette.Layout
  tagName: 'tr'
  template: JST['users/row']

  initialize: ->
    @listenTo @model, 'change', @onChange
    @initVisibilitytListeners()

  initVisibilitytListeners: ->
    @listenTo(@model, 'toggle_visible', @toggleVisibility)
    @listenTo(EventAggregator, 'UsersRow:toggleEnding', @highlightEnding)

    @listenTo(EventAggregator, 'UsersRow:showOnlyIfArchived', @visibleOnlyIfArchived)
    @listenTo(EventAggregator, 'UsersRow:showOnlyIfPotential', @visibleOnlyIfPotential)

  events:
    'keypress .employment': 'filterEmploymentKeyPress'
    'keypress .phone': 'filterPhoneKeyPress'

  regions:
    projectsRegion: '.projects-region'
    nextProjectsRegion: '.next_projects-region'
    potentialProjectsRegion: '.potential_projects-region'

  bindings:
    '.employment': 'employment'
    '.phone': 'phone'
    '.roles':
      observe: 'role_id'
      selectOptions:
        collection: -> gon.roles
        labelPath: 'name'
        valuePath: '_id'
        defaultOption:
          label: "no role"
          value: null
    '.admin_role': 'admin_role_id'
    '.locations':
      observe: 'location_id'
      selectOptions:
        collection: -> gon.locations
        labelPath: 'name'
        valuePath: '_id'
        defaultOption:
          label: 'choose'
          value: null

  onRender: ->
    @stickit()
    role = @model.get("role")
    @$el.find('.roles').val(role._id) if role
    location = @model.get("location")
    @$el.find('.locations').val(location._id) if location
    @toggleVisibility(@model.isActive())
    @renderProjectsRegion()
    @renderNextProjectsRegion()
    @renderPotentialProjectsRegion()

  renderProjectsRegion: ->
    collectProjects = new Backbone.Collection @model.get('projects')
    projectsView = new Hrguru.Views.UsersProjects
      collection: collectProjects
      show_dates: false
      header: "current"
      role: @model.get("role")
    @projectsRegion.show projectsView

  renderNextProjectsRegion: ->
    collectProjects = new Backbone.Collection @model.get('next_projects')
    projectsView = new Hrguru.Views.UsersProjects
      collection: collectProjects
      show_dates: true
      header: "next"
      role: @model.get("role")
    @nextProjectsRegion.show projectsView

  renderPotentialProjectsRegion: ->
    collectProjects = new Backbone.Collection @model.get('potential_projects')
    projectsView = new Hrguru.Views.UsersProjects
      show_dates: false
      collection: collectProjects
      header: "potential"
      role: @model.get("role")
    @potentialProjectsRegion.show projectsView

  onChange: (o, trigger)->
    return unless trigger.stickitChange?
    attrObj = @model.changedAttributes()
    attrName = _.keys(attrObj)[0]
    $input = @$el.find(".#{attrName}")
    @model.save(attrObj,
      patch: true,
      success: (model, response, options) =>
        @hideError($input)
        thName = $('table').find('th').eq($input.closest('td').index()).text()
        Messenger().success("#{thName} has been updated")
      error: (model, xhr) => @showError($input, xhr.responseJSON.errors)
    )

  showError: ($element, errorsJSON = {}) ->
    for attr, errors of errorsJSON
      Messenger().error(msg) for msg in errors
    $element.wrap("<div class='has-error'></div>") unless @hasError($element)

  hideError: ($element) ->
    $element.unwrap() if @hasError($element)

  hasError: ($element) ->
    $element.parent().is('div.has-error')

  filterEmploymentKeyPress: (event) ->
    keycode = event.keyCode
    value = "#{event.target.value}#{(H.numberFromKeyCodes(keycode))}"
    H.isNumber(keycode) and (200 >= value and value >= 0)

  filterPhoneKeyPress: (event) ->
    H.isNumber(event.keyCode)

  highlightEnding: (state) ->
    daysToEnd = @model.daysToAvailable()
    unless state
      return @$el.show() unless @model.get('archived')
    if daysToEnd >= 0
      @$el.toggleClass("left-#{daysToEnd}", state)
    else
      @$el.hide()

  toggleVisibility: (state) ->
    if state then @$el.show() else @$el.hide()

  visibleOnlyIfArchived: (state) ->
    if @model.get('archived')
      @toggleVisibility(state)
    else
      @toggleVisibility(!state)

  visibleOnlyIfPotential: (state) ->
    @togglePotentialProject(state)
    daysToEnd = @model.daysToAvailable()
    unless state
      return @$el.show() unless @model.get('archived')
    if @model.isPotential()
      @$el.toggleClass("left-#{daysToEnd}", state) if daysToEnd?
    else
      @$el.hide()

  togglePotentialProject: (state) ->
    @$el.find('.project.potential').toggleClass('hide', !state)
