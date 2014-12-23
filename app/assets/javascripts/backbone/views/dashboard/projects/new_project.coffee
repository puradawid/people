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
    internal:  '.internal'
    kickoff:   '.kickoff'
    project_type: '#project-type'
    form:      '.new-project-form'
    add:       '.new-project-add'
    devs:      '.devs'
    qas:       '.qas'
    pms:       '.pms'

  initialize: ->
    @developers = new Hrguru.Collections.Users(gon.developers)
    @project_managers = new Hrguru.Collections.Users(gon.project_managers)
    @qality_assurance = new Hrguru.Collections.Users(gon.quality_assurance)
    super()

  initSelectize: ->
    @initializeDeveloperSelectize()
    @initializeProjectManagerSelectize()
    @initializeQualityAssuranceSelectize()

  toggleFormClass: ->
    @clearInputs()

  addProject: ->
    attributes =
      project:
        name: @ui.name.val()
        slug: @ui.slug.val()
        end_at: @ui.endAt.val()
        potential: @ui.potential.prop('checked')
        internal: @ui.internal.prop('checked')
        kickoff: @ui.kickoff.val()
        archived: false
        project_type: @ui.project_type.val()
    @collection.create attributes,
       wait: true
       success: @projectCreated
       error: @projectError


  projectCreated: (project) =>
    @createMemberships(project)
    project_name = project.get('name')
    Messenger().success("#{project_name} has been created")
    @toggleFormClass()
    location.reload()

  createMemberships: (project) ->
    _.each @developers_selectize.getValue().split(","), (developer) ->
      @['this'].addToProject(@['project'], developer)
    , { this: @, project: project }


  addToProject: (project, user) ->
    attributes =
      membership :
        starts_at: Date()
        user_id: user
        project_id: project.id
        role_id: @developers.get(user).attributes.role_id
        billable: true
    @collection.get(project).attributes.memberships.create(attributes)

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
    @ui.internal.prop('checked')
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
      options: @qality_assurance.toJSON()
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
