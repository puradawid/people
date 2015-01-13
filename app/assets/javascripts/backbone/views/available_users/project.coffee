class Hrguru.Views.AvailableUsersProjectEmpty extends Marionette.ItemView
  template: JST['available_users/empty_project']

  initialize: (options) ->
    @header = options.header

  serializeData: ->
    _.extend super,
      header: @header

class Hrguru.Views.AvailableUsersProject extends Marionette.ItemView
  template: JST['available_users/project']

  initialize: (options) ->
    @role = options.role
    @show_start_date = options.show_start_date
    @show_end_date = options.show_end_date

  serializeData: ->
    _.extend super,
      role: @role
      show_start_date: @show_start_date
      show_end_date: @show_end_date
      is_role_technical: @role? && @role.technical
