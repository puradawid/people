class Hrguru.Views.Dashboard.EditMembershipPopup extends Marionette.CompositeView

  className: 'editPopup'
  template: JST['dashboard/projects/memberships/edit_membership_popup']

  events:
    'click .submit' : 'updateMembership'
    'click .close_btn' : 'clearForm'
    'click .close' : 'clearForm'

  ui:
    input_starts_at: '.starts_at'
    input_ends_at: '.ends_at'
    billable: '.billable'

  initialize: ->
    @$el.prop 'id', @model.get('id')

  onRender: ->
    @initDatePicker()
    @fillMembershipPopupForm()

  initDatePicker: ->
    @$el.find('input.date_picker').datepicker
      autoclose: true
      todayHighlight: true
      format: "yyyy-mm-dd"

  input_date: (date) ->
    return '' unless date?
    moment(date).format 'YYYY-MM-DD'

  fillMembershipPopupForm: ->
    @ui.input_starts_at.val @input_date @model.get('starts_at')
    @ui.input_ends_at.val @input_date @model.get('ends_at')
    @ui.billable.prop('checked', @model.get('billable'))
    @hideErrors()

  clearForm: ->
    @fillMembershipPopupForm()

  updateMembership: (event) ->
    return unless confirm("Are you sure?")
    event.preventDefault()
    @hideErrors()
    @model.save({starts_at: @ui.input_starts_at.val(), ends_at: @ui.input_ends_at.val(), billable: @ui.billable.prop('checked')},
      patch: true
      success: (model, response, options) =>
        Messenger().success('Membership has been updated')
        @$el.modal('hide')
      error: (model, xhr) =>
        @showError(xhr.responseJSON.errors)
    )
    @model.set('visible', true)
    if @model.changed.hasOwnProperty('billable')
      @model.trigger('membership:updated:billable', @model)

  showError: (errorsJSON = {}) ->
    for attr, errors of errorsJSON
      $input = @$el.find(".#{attr}").parent().parent()
      Messenger().error("#{attr} #{msg}") for msg in errors
      $input.addClass 'has-error' unless @hasError($input)

  hideErrors: ->
    $.each @$el.find('input'), (i, element) ->
      $(element).parent().parent().removeClass('has-error')

  hasError: ($element) ->
    $element.hasClass('has-error')
