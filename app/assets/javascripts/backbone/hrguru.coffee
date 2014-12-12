#= require_self
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./models
#= require_tree ./lib
#= require ./helper


window.EventAggregator = new Backbone.Wreqr.EventAggregator()

window.Hrguru =
  Models: {}
  Collections: {}
  Views:
    Dashboard: {}

  init: ->
    view_name = $('body').data('view')
    @current_view = new Hrguru.Views[view_name]() if Hrguru.Views[view_name]?
    @alertView ||=  new Hrguru.Views.Alert()
    @alertView.checkMessages()

$ ->
  window.H = new Hrguru.Helper()
  Hrguru.init()
