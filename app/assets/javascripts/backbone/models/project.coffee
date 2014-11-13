class Hrguru.Models.Project extends Backbone.AssociatedModel

  relations: [
    {
      type: Backbone.Many,
      key: 'notes',
      collectionType: 'Hrguru.Collections.Notes'
    },
    {
      type: Backbone.Many,
      key: 'memberships',
      collectionType: 'Hrguru.Collections.Memberships'
    }
  ]

  defaults:
    memberships: []

  isActive: ->
    !(@get('potential') || @get('archived') || @get('internal'))

  isPotential: ->
    @get('potential')

  isArchived: ->
    @get('archived')

  isInternal: ->
    @get('internal')

  type: ->
    return 'potential' if @isPotential()
    return 'archived' if @isArchived()
    return 'internal' if @isInternal()
    'active'

  daysToEnd: ->
    return null unless @get('end_at')?
    moment(@get('end_at')).diff(H.currentTime(), 'days')

class Hrguru.Collections.Projects extends Backbone.Collection
  model: Hrguru.Models.Project
  url: Routes.projects_path()
