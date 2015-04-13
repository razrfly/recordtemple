jQuery ->
  $('.sortable').sortable
    axis: 'y'
    handle: '.draggable'
    update: ->
      $.post( $(this).data('update-url'), $(this).sortable('serialize') )