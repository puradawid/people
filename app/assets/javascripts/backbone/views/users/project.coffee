class Hrguru.Views.UsersProjectEmpty extends Marionette.ItemView
  template: JST['users/empty_project']

  initialize: (options) ->
    @header = options.header

  serializeData: ->
    _.extend super,
      header: @header

class Hrguru.Views.UsersProject extends Marionette.ItemView
  template: JST['users/project']

  initialize: (options) ->
    @role = options.role
    @show_dates = options.show_dates

  serializeData: ->
    _.extend super,
      role: @role
      show_dates: @show_dates
      is_role_technical: @role? && @role.technical
