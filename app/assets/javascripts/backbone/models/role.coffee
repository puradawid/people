class Hrguru.Models.Role extends Backbone.Model
  urlRoot: Routes.roles_path()

class Hrguru.Collections.Roles extends Backbone.Collection
  model: Hrguru.Models.Role

  comparator: (model) -> model.get('priority')
