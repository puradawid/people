class Hrguru.Models.Membership extends Backbone.Model

  started: ->
    H.currentTime() > moment(@get('starts_at'))

  daysToStart: ->
    return null unless @get('starts_at')?
    moment(@get('starts_at')).diff(H.currentTime(), 'days')

  daysToEnd: ->
    return null unless @get('ends_at')?
    moment(@get('ends_at')).diff(H.currentTime(), 'days')

  hasTechnicalRole: (role) ->
    role.get('technical')

  isBillable: ->
    @get('billable')

  hasEndDate: ->
    @get('ends_at')?

  unFinished: ->
    return true unless @get('ends_at')
    moment(@get('ends_at')) > H.currentTime()

class Hrguru.Collections.Memberships extends Backbone.Collection
  model: Hrguru.Models.Membership
  url: Routes.memberships_path()

  forProject: (project_id, roles) ->
    result = []
    base = @where(project_id: project_id)

    roles.each (role) ->
      filtered_by_role = _.select base, (m) -> m.get('role_id') == role.id
      result.push.apply(result, filtered_by_role)

    new Hrguru.Collections.Memberships(result)

  unFinished: ->
    result = _.select @models, (m) -> m.unFinished()
    new Hrguru.Collections.Memberships(result)
