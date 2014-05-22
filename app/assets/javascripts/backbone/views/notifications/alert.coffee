class Hrguru.Views.Alert extends Backbone.View
  el: 'body'

  checkMessages: ->
    @flash = gon.flash
    return unless @flash
    @displayNotice() if @flash.notice
    @displayAlert() if @flash.alert

  displayAlert: ->
    _.each @flash.alert, (msg) ->
      Messenger().error(msg)
    @clearDisplayedMessages('alert')

  displayNotice: ->
    _.each @flash.notice, (msg) ->
      Messenger().success(msg)
    @clearDisplayedMessages('notice')

  clearDisplayedMessages: (type) ->
    gon.flash[type] = @flash[type] = []
