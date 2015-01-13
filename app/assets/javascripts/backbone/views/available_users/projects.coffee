class Hrguru.Views.AvailableUsersProjects extends Marionette.CompositeView
  template: JST['available_users/projects']

  itemView: Hrguru.Views.AvailableUsersProject
  emptyView: Hrguru.Views.AvailableUsersProjectEmpty
  itemViewContainer: '.projects'

  itemViewOptions: ->
    role: @role
    header: @header
    show_start_date: @show_start_date
    show_end_date: @show_end_date

  initialize: (options) ->
    { @role, @header, @show_start_date, @show_end_date } = options

  serializeData: ->
    _.extend super,
      header: @header
