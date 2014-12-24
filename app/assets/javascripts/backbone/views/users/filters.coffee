class Hrguru.Views.UsersFilters extends Marionette.View

  el: '#filters'

  ui:
    checkboxes:
      highlight: '#highlight-ending'
      archived: '#show-archived'
      has_project: '#show-without-project'

  events:
    'change #highlight-ending' : 'highlightEndingUsers'
    'change #show-archived' : 'showOnlyBy'
    'change #show-without-project' : 'showOnlyBy'

  initialize: (@projects, @roles, @users, @locations, @abilities, @months) ->
    @listenTo(EventAggregator, 'UsersRow:toggleEnding', @toggleEndingTime)
    @listenTo(EventAggregator, 'UsersRow:showOnlyIfPotential', @toggleEndingTime)
    @initializeVariables()

  render: ->
    @initializeUserFilter()
    @initializeRoleFilter()
    @initializeProjectFilter()
    @initializeAbilitiesFilter()
    @initializeMonthsInCurrentProjectFilter()

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
    @selectize.users = users_selectize[0].selectize.items

  initializeRoleFilter: ->
    roles_selectize = @$('input[name=roles]').selectize
      plugins: ['remove_button']
      create: false
      valueField: '_id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'priority'
      options: @roles.toJSON()
      onItemAdd: @filterUsers
      onItemRemove: @filterUsers
    @selectize.roles = roles_selectize[0].selectize.items

  initializeProjectFilter: ->
    projects_selectize = @$('input[name=projects]').selectize
      plugins: ['remove_button']
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @projects.toJSON()
      onItemAdd: @filterUsers
      onItemRemove: @filterUsers
    @selectize.projects = projects_selectize[0].selectize.items

  initializeAbilitiesFilter: ->
    abilities_selectize = @$('input[name=abilities]').selectize
      plugins: ['remove_button']
      create: false
      valueField: '_id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @abilities
      onItemAdd: @filterUsers
      onItemRemove: @filterUsers
    @selectize.abilities = abilities_selectize[0].selectize.items

  initializeMonthsInCurrentProjectFilter: ->
    months_in_current_project_selectize = @$('select[name=months]').selectize
      create: false
      valueField: 'value'
      sortField: 'value'
      labelField: 'text'
      options: @months
    months_in_current_project_selectize.change @, @updateSelectizeMonths
    @selectize.months = months_in_current_project_selectize[0].selectize.items[0]

  filterUsers: =>
    EventAggregator.trigger('users:updateVisibility', @selectize)
    H.addUserIndex()

  updateSelectizeMonths: (e) =>
    @selectize.months = $(e.target).first().val()
    @filterUsers()

  initializeVariables: ->
    @selectize =
      roles: []
      projects: []
      locations: []
      users: []
      abilities: []
      months: []

  highlightEndingUsers: (event) ->
    checkbox = event.currentTarget
    state = checkbox.checked
    type = checkbox.dataset.type
    @hideFiltersAndSorts(state)
    @toggleCheckboxes(type, state)
    EventAggregator.trigger('user:sortAndHighlightEnding', state)
    H.addUserIndex()

  showOnlyBy: (event) ->
    checkbox = event.currentTarget
    state = checkbox.checked
    type = checkbox.dataset.type
    @hideFiltersAndSorts(state)
    @toggleCheckboxes(type, state)
    @showOnlyByArchive(state) if type == 'archived'
    @showOnlyByPotential(state) if type == 'has_project'
    H.addUserIndex()

  showOnlyByArchive: (state) ->
    EventAggregator.trigger('UsersRow:showOnlyIfArchived', state)

  showOnlyByPotential: (state) ->
    EventAggregator.trigger('user:sortBeforePotential', state)

  hideFiltersAndSorts: (state) ->
    @$el.find('.filters').stop().slideToggle(state)
    $('.sort').stop().fadeToggle(state)

  toggleCheckboxes: (type, state) ->
    _.each @ui.checkboxes, (checkbox, key) =>
      $(checkbox).attr(disabled: state) unless type == key

  toggleEndingTime: (state) ->
    if state
      $('.to_end').show "fade"
    else
      $('.to_end').hide "fade", 100
