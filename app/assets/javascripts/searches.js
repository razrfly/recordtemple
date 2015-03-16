$(document).ready(function(){


  var searchableThings = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("name"),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: "/search.json?q=%QUERY",
  });

  searchableThings.initialize();

  $("#js_search_box .typeahead").typeahead(null, {
    displayKey: function(obj){
      return obj.name + " (" + obj.type + ")"
    },
    source: searchableThings.ttAdapter()
  });

  // $("#search-box .typeahead").on("typeahead:selected", function(object, datum){
  //   window.location = datum.path;
  // })

});