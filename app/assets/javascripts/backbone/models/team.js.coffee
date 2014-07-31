class Hrguru.Models.Team extends Backbone.Model
  relations: [
    {
      type: Backbone.HasMany,
      key: 'users',
      collectionType: 'Hrguru.Collections.Users'
    }
  ]

  defaults:
    users: []

class Hrguru.Collections.Teams extends Backbone.Collection
  model: Hrguru.Models.Team
  url: Routes.teams_path()
