class Hrguru.Views.ProjectsEdit extends Backbone.View
  initialize: ->
    $('#project_potential').on('change', @toggleProjectMembership)
    @potential = $('.project_potential').find('#project_potential').is(':checked')

  toggleProjectMembership: (event) =>
    $('#project-membership').toggle() if @potential


