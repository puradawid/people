readURL = (input) ->
  if input.files && input.files[0]
    reader = new FileReader()
    reader.onload = (e) ->
      $('.icon-preview__image').attr('src', e.target.result)
    reader.readAsDataURL(input.files[0])

$ ->
  $('.ability_icon input').change ->
    readURL(this)
