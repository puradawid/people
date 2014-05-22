class Hrguru.Models.Note extends Backbone.Model

class Hrguru.Collections.Notes extends Backbone.Collection
  model: Hrguru.Models.Note
  url: Routes.notes_path()
