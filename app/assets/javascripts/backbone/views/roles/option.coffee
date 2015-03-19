class Hrguru.Views.RoleOption extends Backbone.Marionette.ItemView
  tagName: 'option'

  attributes: ->
    selected: @model.get('selected')
    value: @model.get('value')

  render: ->
    @$el.html(@model.get('text'))

    this


