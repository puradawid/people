class Hrguru.Views.ProjectsShow extends Backbone.View
  el: '#main-container'

  initialize: ->
    elTimeline = @$(".timeline")
    @timeline = elTimeline.timeline(gon.events, gon.project)
    elTimeline.scrollTo(elTimeline[0].scrollWidth, 0)
    @$el.after @timeline
