class Hrguru.Views.Dashboard.Filters extends Backbone.View

  el: '#filters'

  events:
    'change #highlight-ending' : 'highlightEndingChanged'
    'change #show-next' : 'showNextChanged'
    'change #highlight-not-billable' : 'highlightNotBillableChanged'
    'change .toggle-by-type' : 'toggleByType'

  availableCheckboxes:
    'active' : ['highlight-ending', 'show-next', 'highlight-not-billable']
    'potential' : ['show-next', 'highlight-not-billable']
    'archived' : ['highlight-not-billable']

  initialize: (@projects, @roles, @users) ->
    $(window).on("unload",@saveRadioState)
    @displayedType = 'active'
    @retriveRadioState()

  render: ->
    @initializeRoleFilter()
    @initializeProjectFilter()
    @initializeUserFilter()
    @setupForCheckboxStates()

  initializeProjectFilter: ->
    projects_selectize = @$('input[name=projects]').selectize
      plugins: ['remove_button']
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @filterSelectizeProjects()
      onItemAdd: @filterProjects
      onItemRemove: @filterProjects
    @projects_selectize = projects_selectize[0].selectize

  initializeRoleFilter: ->
    roles_selectize = @$('input[name=roles]').selectize
      plugins: ['remove_button']
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'priority'
      options: @roles.toJSON()
      onItemAdd: @filterRoles
      onItemRemove: @filterRoles
    @roles_selectize = roles_selectize[0].selectize

  initializeUserFilter: ->
    users_selectize = @$('input[name=users]').selectize
      plugins: ['remove_button']
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @users.toJSON()
      onItemAdd: @filterUsers
      onItemRemove: @filterUsers
    @users_selectize = users_selectize[0].selectize

  setupForCheckboxStates: ->
    $('#highlight-ending').trigger 'change'
    $('#show-next').trigger 'change'
    $('#highlight-not-billable').trigger 'change'

  filterSelectizeProjects: ->
    filtered_projects = []
    _.each(@projects.models, (item) =>
      filtered_projects.push item.toJSON() if item.type() is @displayedType)
    filtered_projects

  filterProjects: =>
    EventAggregator.trigger('projects:toggleVisibility', @projects_selectize.items)

  filterRoles: =>
    EventAggregator.trigger('roles:toggleVisibility', @roles_selectize.items)

  filterUsers: =>
    EventAggregator.trigger('projects:toggleByUsers', @users_selectize.items)
    EventAggregator.trigger('memberships:toggleByUsers', @users_selectize.items)

  highlightEndingChanged: (event) ->
    EventAggregator.trigger('project:highlightEnding', event.currentTarget.checked)
    EventAggregator.trigger('memberships:highlightEnding', event.currentTarget.checked)

  showNextChanged: (event) ->
    EventAggregator.trigger('memberships:showNext', event.currentTarget.checked)

  highlightNotBillableChanged: (event) ->
    EventAggregator.trigger('memberships:highlightNotBillable', event.currentTarget.checked)

  toggleByType: (event) =>
    @displayedType = event.currentTarget.dataset.type
    H.togglePotentialCheckbox(@displayedType)
    @refreshProjectSelectize()
    @refreshFilterCheckboxes()
    EventAggregator.trigger('projects:toggleByType', { type: @displayedType })

  retriveRadioState: ->
    distype = null
    @$('input.toggle-by-type').each ->
      state = JSON.parse( localStorage.getItem('radio_'  + @getAttribute('data-type')) )
      if state?.checked
        @checked =  true
        distype = @getAttribute('data-type')
        EventAggregator.trigger('projects:toggleByType', { type: @getAttribute('data-type') })
    @displayedType = distype
    @refreshFilterCheckboxes()
    H.togglePotentialCheckbox(@displayedType)

  saveRadioState: ->
    @$('input.toggle-by-type').each ->
      localStorage.setItem(
        'radio_' + this.getAttribute('data-type'), JSON.stringify({checked: this.checked})
      )

  refreshProjectSelectize: ->
    if @projects_selectize?
      @projects_selectize.clear()
      @filterProjects()
      @projects_selectize.clearOptions()
      @projects_selectize.load (callback) =>
        callback @filterSelectizeProjects()

  refreshFilterCheckboxes: ->
    $('.checkboxes .checkbox').hide()
    _.each @availableCheckboxes[@displayedType], (type) ->
      $("##{type}").parents('.checkbox').show()
