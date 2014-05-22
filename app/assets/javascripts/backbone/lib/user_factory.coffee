@UserFactory =

  basedOnRole: (role) ->
    base = new Hrguru.Models.User()
    base.set('role_id', role.get('id'))
    base
