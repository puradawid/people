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
      options: @projects.toJSON()
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

  filterProjects: =>
    EventAggregator.trigger('projects:toggleVisibility', @projects_selectize.items)

  filterRoles: =>
    EventAggregator.trigger('roles:toggleVisibility', @roles_selectize.items)

  highlightEndingChanged: (event) ->
    EventAggregator.trigger('project:highlightEnding', event.currentTarget.checked)
    EventAggregator.trigger('memberships:highlightEnding', event.currentTarget.checked)

  showNextChanged: (event) ->
    EventAggregator.trigger('memberships:showNext', event.currentTarget.checked)

  highlightNotBillableChanged: (event) ->
    EventAggregator.trigger('memberships:highlightNotBillable', event.currentTarget.checked)

  toggleByType: (event) ->
    @displayedType = event.currentTarget.dataset.type
    EventAggregator.trigger('projects:toggleByType', { type: @displayedType })

  retrive_radio_state: ->
    @$('input#toggle-by-type').each ->
      state = JSON.parse( localStorage.getItem('radio_'  + this.getAttribute('data-type')) )
      if state && state.checked
        this.checked =  true
        EventAggregator.trigger('projects:toggleByType', { type: this.getAttribute('data-type') })


  save_radio_state: ->
    @$('input#toggle-by-type').each ->
      localStorage.setItem(
        'radio_' + this.getAttribute('data-type'), JSON.stringify({checked: this.checked})
      )
