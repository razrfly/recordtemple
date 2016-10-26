initialize_selectize_remote = (selectize_remote) ->
  $selectize_remote = $(selectize_remote)
  $selectize_remote.selectize(
    plugins: ['remove_button']
    valueField: 'id'
    labelField: 'name'
    searchField: ['name']
    selectOnTab: true
    closeAfterSelect: true

    load: (query, callback) ->
      if !query.length
        return callback()
      $.ajax
        url: $selectize_remote.data('remote-url')
        data:
          q: query
        error: ->
          callback()
        success: (res) ->
          callback res
  )

jQuery ->
  $('.selectize_remote').each ->
    initialize_selectize_remote(this)
