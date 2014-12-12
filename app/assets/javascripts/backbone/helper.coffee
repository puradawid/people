class Hrguru.Helper

  constructor: (options)->
    @time_now = moment()
    @server_time = gon.currentTime if gon?
    @current_user = new Hrguru.Models.User(gon.current_user)
    @setMessengerOptions()
    @addViewHelpers()
    moment().lang('en')

  currentTime: ->
    moment(@server_time).add(moment().diff(@time_now))

  addUserIndex: ->
    index = 0
    $table = $('#users tbody')
    $table.find('#summary').remove()
    $.each($table.find('tr'), (i, row) ->
      $(row).find('td:first').text(++index) if $(row).css('display') is 'table-row')

    $summary = JST['users/summary_row'](count: index)
    $table.append($summary)

  addViewHelpers: ->
    HAML.globals = ->
      globals = {}

      for key, template of JST
        if helper = key.match /^helpers\/(.+)/
          globals[helper[1]] = template

      facadeCall = (helper, params) ->
        globals[helper] = (values...) ->
          JST["helpers/#{helper}"](values.reduce (x, value) ->
            param = params[values.indexOf value]
            x[param] = value
            x
          , {})

      facadeCall 'profile_link', ['user', 'link']
      facadeCall 'link_to', ['name', 'link']
      facadeCall 'icon', ['name']
      globals

  setMessengerOptions: ->
    Messenger.options =
      extraClasses: 'messenger-fixed messenger-on-top messenger-on-right'
      theme: 'flat'
      messageDefaults:
        hideAfter: 5

  currentUserIsAdmin: ->
    @current_user.get('admin')

  currentUserIdIs: (user_id)->
    @current_user.get('id') == user_id

  isNumber: (keycode) ->
    (keycode >= 48 and keycode <= 57)

  numberFromKeyCodes: (keycode) ->
    return false unless @isNumber(keycode)
    zeroKeycode = 48
    keycode - zeroKeycode

  togglePotentialCheckbox: (type) ->
    $('.potential').prop('checked', type is 'potential')
  toggleInternalCheckbox: (type) ->
    $('.internal').prop('checked', type is 'internal')
