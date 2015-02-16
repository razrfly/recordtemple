$(document).ready(function() {
  $('#record-artist').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    valueField: 'id',
    labelField: 'name',
    searchField: ['name'],
    sortField: 'name',
    loadThrottle: 500,
    load: function(query, callback){
      $.ajax({
        data: {q: {name_cont: query}},
        url: '/admin/artists.json',
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
        url: '/admin/artists.json',
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

  $('#record-label').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    valueField: 'id',
    labelField: 'name',
    searchField: ['name'],
    sortField: 'name',
    loadThrottle: 500,
    load: function(query, callback){
      $.ajax({
        data: {q: {name_cont: query}},
        url: '/admin/labels.json',
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
        url: '/admin/labels.json',
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

  $('#record-condition').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    loadThrottle: 200,
  });

  $('#record-genre').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    loadThrottle: 200,
  });

  $('#record-format').selectize({
    plugins: ['remove_button'],
    persist: false,
    maxItems: 1,
    loadThrottle: 200,
  });

  $('#record-price').focusout(function(){
    id = $(this).val();
    if (id){
      $.ajax({
        //data: {q: {name_cont: query}},
        url: '/admin/prices/'+ id + '.json',
        type: 'GET',
        dataType: 'json',
        error: function() {
          $('#record-price').css('border', '1px solid red');
          // alert('trala')
        },
        success: function(res) {
          $('#record-price').css('border', 'none');
          $('#dis-record-artist').val(res.artist)
          $('#dis-record-label').val(res.label)
          $('#dis-record-format').val(res.format)
        }
      });
    }
  });

});
