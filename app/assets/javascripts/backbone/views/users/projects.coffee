class Hrguru.Views.UsersProjects extends Marionette.CompositeView
  template: JST['users/projects']

  itemView: Hrguru.Views.UsersProject
  emptyView: Hrguru.Views.UsersProjectEmpty
  itemViewContainer: '.projects'

  itemViewOptions: ->
    role: @role
    header: @header
    show_dates: @show_dates

  initialize: (options) ->
    { @role, @header, @show_dates } = options

  serializeData: ->
    _.extend super,
      header: @header
