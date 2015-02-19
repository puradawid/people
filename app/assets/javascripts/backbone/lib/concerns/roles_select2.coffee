@Hrguru.Concerns.RolesSelect2 =

  rolesSelect2: (el) ->
    el.select2
      multiple: true
      initSelection: (element, callback) =>
        $.getJSON Routes.api_roles_path(), { ids: @role_ids(el) }, (data) ->
          callback data.roles

      ajax:
        url: Routes.api_roles_path()
        datatype: 'json'
        data: (term, page) ->
          {
            per: 25
            page: page
            term: term
          }
        results: (data, page) ->
          more = page < data.meta.total_pages
          { results: data.roles, more: more }

      formatResult: @role_pretty_name
      formatSelection: @role_pretty_name

  role_pretty_name: (role) ->
    role.name

  role_ids: (el) ->
    el.val()
