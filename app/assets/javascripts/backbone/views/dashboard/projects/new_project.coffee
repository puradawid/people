class Hrguru.Views.Dashboard.NewProject extends Marionette.ItemView

  className: 'new-project'
  template: JST['dashboard/projects/new_project']

  events:
    'click .new-project-add': 'initSelectize'
    'click .new-project-add, .new-project-close' : 'toggleFormClass'
    'click .new-project-submit' : 'addProject'

  ui:
    name:      '.name'
    slug:      '.slug'
    endAt:     '.endAt'
    potential: '.potential'
    kickoff:   '.kickoff'
    project_type_select: '#project-type'
    form:      '.new-project-form'
    add:       '.new-project-add'
    devs:      '.devs'
    qas:       '.qas'
    pms:       '.pms'
    modal:     '.add-project-modal'

  initialize: ->
    @developers = new Hrguru.Collections.Users(gon.developers)
    @project_managers = new Hrguru.Collections.Users(gon.project_managers)
    @quality_assurance = new Hrguru.Collections.Users(gon.quality_assurance)
    @all_users = new Hrguru.Collections.Users(gon.users)
    @roles = new Hrguru.Collections.Roles(gon.roles)
    super()

  initSelectize: ->
    @initializeDeveloperSelectize()
    @initializeProjectManagerSelectize()
    @initializeQualityAssuranceSelectize()

  toggleFormClass: ->
    @clearInputs()

  addProject: ->
    membershipsArray = []
    membershipsArray = @membershipsAsArray()
    project_type =
      switch(@ui.project_type_select.val())
        when 'Regular' then 'regular'
        when 'Maintenance - development' then 'maintenance_development'
        when 'Maintenance - support' then 'maintenance_support'
    attributes =
      project:
        name: @ui.name.val()
        slug: @ui.slug.val()
        end_at: @ui.endAt.val()
        potential: @ui.potential.prop('checked')
        internal: false
        kickoff: @ui.kickoff.val()
        archived: false
        project_type: project_type
        memberships_attributes: membershipsArray
      memberships: membershipsArray
    @collection.create attributes,
       wait: true
       success: @projectCreated
       error: @projectError

  membershipsAsArray: () ->
    membershipsArray = []
    _.each @selectizeUsers().split(","), (user) ->
      return if user.length < 1
      @['this'].newMembership(user, membershipsArray)
    , { this: @, membershipsArray: membershipsArray }
    membershipsArray

  newMembership: (user, membershipsArray) ->
    role_id =  @all_users.get(user).attributes.role_id
    membership_attribute =
      starts_at: Date()
      user_id: user
      role_id: role_id
      billable: @roles.get(role_id).get('billable')
    membershipsArray.push(membership_attribute)

  projectCreated: (project) =>
    project_name = project.get('name')
    Messenger().success("#{project_name} has been created")
    @toggleFormClass()
    @hideModal()

  hideModal: ->
    @ui.modal.modal('hide')

  selectizeUsers: =>
    @developers_selectize.getValue() + ',' + @qas_selectize.getValue() + ',' + @pms_selectize.getValue()

  removeFromSelectize: (user) ->
    @developers_selectize.removeOption(user)
    @qas_selectize.removeOption(user)
    @pms_selectize.removeOption(user)

  projectError: (project, request) =>
    error_massage = _.map request.responseJSON.errors, (value, key) =>
      "#{key}: " + _.map value, (msg) =>
        msg
    Messenger().error(error_massage.join())

  clearInputs: ->
    @ui.name.val('')
    @ui.slug.val('')
    @ui.endAt.val('')
    @ui.kickoff.val('')
    @ui.potential.prop('checked')
    @developers_selectize.clear()
    @qas_selectize.clear()
    @pms_selectize.clear()

  initializeDeveloperSelectize: ->
    developers_selectize = @$('input[name=devs]').selectize
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @developers.toJSON()
    @developers_selectize = developers_selectize[0].selectize

  initializeQualityAssuranceSelectize: ->
    qas_selectize = @$('input[name=qas]').selectize
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @quality_assurance.toJSON()
    @qas_selectize = qas_selectize[0].selectize

  initializeProjectManagerSelectize: ->
    pms_selectize = @$('input[name=pms]').selectize
      create: false
      valueField: 'id'
      labelField: 'name'
      searchField: 'name'
      sortField: 'name'
      options: @project_managers.toJSON()
    @pms_selectize = pms_selectize[0].selectize
