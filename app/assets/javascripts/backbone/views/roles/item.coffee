class Hrguru.Views.RolesEmptyRow extends Backbone.Marionette.ItemView
  tagName: 'li'
  template: JST['roles/empty_row']

class Hrguru.Views.RolesRow extends Backbone.Marionette.ItemView
  tagName: 'li'
  id: -> "role_#{@model.get('id')}"
  template: JST['roles/row']

  initialize: -> @addInputHandler()

  bindings:
    '.name': 'name'
    '.color': 'color'
    '.billable': 'billable'
    '.technical': 'technical'
    '.show-in-team' : 'show_in_team'

  onRender: ->
    @stickit()

  addInputHandler: ->
    Backbone.Stickit.addHandler
      selector: '.name,.color,.billable,.technical,.show-in-team'
      events: ['change']
      onSet: 'update'

  update: (val, options) ->
    attr_name = options.observe
    @input = @$(".#{attr_name}")
    attr = {}
    attr[attr_name] = val
    @model.save(attr,
      patch: true
      success: => @hideError()
      error: (model, xhr) => @showError(xhr.responseJSON.errors)
    )

  showError: (errorsJSON = {}) ->
    for attr, errors of errorsJSON
      Messenger().error("#{attr} #{msg}") for msg in errors

    @input.wrap("<div class='has-error'></div>") unless @hasError()

  hideError: ->
    @input.unwrap() if @hasError()

  hasError: ->
    @input.parent().is('div.has-error')
