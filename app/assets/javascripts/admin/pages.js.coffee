jQuery ->
  $('.remove_cover_link').click (event) ->
    event.preventDefault()
    $('.remove_cover').val('true')
    $('.cover-preview-container, .remove_cover_link').fadeOut()