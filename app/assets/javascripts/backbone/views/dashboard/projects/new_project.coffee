class Hrguru.Views.Dashboard.NewProject extends Marionette.ItemView

  className: 'new-project'
  template: JST['dashboard/projects/new_project']

  events:
    'click .new-project-add, .new-project-close' : 'toggleFormClass'
    'click .new-project-submit' : 'addProject'

  ui:
    name:      '.name'
    slug:      '.slug'
    endAt:     '.endAt'
    potential: '.potential'
    internal:  '.internal'
    kickoff:   '.kickoff'
    form:      '.new-project-form'
    add:       '.new-project-add'

  initialize: ->
    super()

  toggleFormClass: ->
    @ui.form.stop().fadeToggle('fast')
    @ui.add.toggleClass('clicked')
    @clearInputs()

  addProject: ->
    attributes =
      name: @ui.name.val()
      slug: @ui.slug.val()
      end_at: @ui.endAt.val()
      potential: @ui.potential.prop('checked')
      internal: @ui.internal.prop('checked')
      kickoff: @ui.kickoff.val()
    @collection.create attributes,
      wait: true
      success: @projectCreated
      error: @projectError

  projectCreated: (project) =>
    project_name = project.get('name')
    Messenger().success("#{project_name} has been created")
    @toggleFormClass()

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
