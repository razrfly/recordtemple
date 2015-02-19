$(document).ready(function(){
  $('#filters-artist').selectize({
    plugins: ['remove_button'],
    persist: false,
    delimiter: NaN,
    maxItems: 1,
    valueField: 'name',
    labelField: 'name',
    searchField: ['name'],
    sortField: 'name',
    loadThrottle: 500,
    load: function(query, callback){
      $.ajax({
        data: {q: {name_cont: query}},
        url: '/artists.json',
        type: 'PUT',
        dataType: 'json',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });

  $('#filters-label').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    delimiter: NaN,
    valueField: 'name',
    labelField: 'name',
    searchField: ['name'],
    sortField: 'name',
    loadThrottle: 500,
    load: function(query, callback){
      $.ajax({
        data: {q: {name_cont: query}},
        url: '/labels.json',
        type: 'PUT',
        dataType: 'json',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });

  $('#filters-song').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    delimiter: NaN,
    valueField: 'title',
    labelField: 'title',
    searchField: ['title'],
    sortField: 'title',
    loadThrottle: 500,
    load: function(query, callback){
      $.ajax({
        data: {q: {name_cont: query}},
        url: '/songs.json',
        type: 'PUT',
        dataType: 'json',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });


});
