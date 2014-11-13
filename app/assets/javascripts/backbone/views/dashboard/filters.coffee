class Hrguru.Views.Dashboard.Filters extends Backbone.View

  el: '#filters'

  events:
    'change #highlight-ending' : 'highlightEndingChanged'
    'change #show-next' : 'showNextChanged'
    'change #highlight-not-billable' : 'highlightNotBillableChanged'
    'change #toggle-by-type' : 'toggleByType'

  initialize: (@projects, @roles) ->
    $(window).on("unload",@save_radio_state)
    @displayedType = 'active'
    @retrive_radio_state()

  render: ->
    @initializeRoleFilter()
    @initializeProjectFilter()
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

  filterRoles: ->
    EventAggregator.trigger('roles:toggleVisibility', @roles_selectize.items)

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
    @refresh_project_selectize()
    EventAggregator.trigger('projects:toggleByType', { type: @displayedType })

  retrive_radio_state: ->
    distype = null
    @$('input.toggle-by-type').each ->
      state = JSON.parse( localStorage.getItem('radio_'  + @getAttribute('data-type')) )
      if state?.checked
        @checked =  true
        distype = @getAttribute('data-type')
        EventAggregator.trigger('projects:toggleByType', { type: @getAttribute('data-type') })
    @displayedType = distype
    H.togglePotentialCheckbox(@displayedType)

  save_radio_state: ->
    @$('input.toggle-by-type').each ->
      localStorage.setItem(
        'radio_' + this.getAttribute('data-type'), JSON.stringify({checked: this.checked})
      )

  refresh_project_selectize: ->
    if @projects_selectize?
      @projects_selectize.clear()
      @filterProjects()
      @projects_selectize.clearOptions()
      @projects_selectize.load (callback) =>
        callback @filterSelectizeProjects()

