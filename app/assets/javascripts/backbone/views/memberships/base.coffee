class Hrguru.Views.BaseMembership extends Backbone.View
  el: '#main-container'

  initialize: ->
    @users = new Hrguru.Collections.Users(gon.users)
    @setDefaultRole()

  events: ->
    'change #membership_user_id': 'setDefaultRole'

  setDefaultRole: ->
    role_id = @currentUser().get('role_id')
    @$('#membership_role_id').val(role_id) if role_id

  currentUser: ->
    id = @$('#membership_user_id').val()
    @users.get(id)
