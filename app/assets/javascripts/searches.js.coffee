jQuery ->
  searchableThings = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term")
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: "/search.json?q=%QUERY"
      wildcard: "%QUERY"
    limit: 15
  )

  searchableThings.initialize()

  $("#scrollable-dropdown-menu.typeahead").typeahead
    hint: false
  ,
    displayKey: (obj) ->
      obj.term + " (" + obj.type + ")"
    source: searchableThings.ttAdapter()

  $("#scrollable-dropdown-menu.typeahead").on "typeahead:selected", (object, datum) ->
    window.location = datum.path
