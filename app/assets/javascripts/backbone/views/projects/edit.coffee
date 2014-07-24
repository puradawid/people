class Hrguru.Views.ProjectsEdit extends Backbone.View

  el: '#main-container'

  events:
    'change #project_potential' : 'toggleProjectMembership'

  initialize: ->
    @potential = $('#project_potential').is(':checked')

  toggleProjectMembership: (event) =>
    $('#project-membership').toggle() if @potential


