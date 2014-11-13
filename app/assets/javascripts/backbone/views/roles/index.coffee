class Hrguru.Views.RolesIndex extends Backbone.View
  el: '#main-container'

  events:
    'click #add-role': 'addItem'

  initialize: ->
    @rolesListView = new Marionette.CollectionView
      collection: new Hrguru.Collections.Roles(gon.roles)
      itemView: Hrguru.Views.RolesRow
      emptyView: Hrguru.Views.RolesEmptyRow
      el: @$('ul#roles')
      tagName: 'ul'

    @rolesListView.$el.sortable
      axis: 'y'
      cursor: 'move'
      items: 'li:not(.no-sortable)'
      update: (event, ui) =>
        $li = $(ui.item)
        $ul = $li.parent()
        role = $li.find('.name').val()
        position = $ul.find('li').index($li)
        $.post(Routes.sort_roles_path(), $ul.sortable('serialize'), ->
          Messenger().success("#{role} has been moved to position #{position}")
        ).fail =>
          @rolesListView.render()
          Messenger().error("Cannot move #{role} to position #{position}")

    @rolesListView.render()

  addItem: (event) ->
    event.preventDefault()
    $input = $('#name')
    $checkboxBillable = $('#billable')
    $checkboxTechnical = $('#technical')
    $checkboxShowInTeam = $('#show-in-team')
    role = new Hrguru.Models.Role()
    role.save(
      name: $input.val(),
      billable: $checkboxBillable.prop('checked'),
      technical: $checkboxTechnical.prop('checked'),
      show_in_team: $checkboxShowIn.prop('checked'),
      success: =>
        $input.val("")
        @rolesListView.collection.add role
    )
