jQuery ->
  $("table#genres").dataTable
    sDom: "<'row'<'col-md-6'l><'col-md-6'f>r>t<'row'<'col-md-12'p i>>"
    aaSorting: []
    oLanguage:
      sLengthMenu: "_MENU_ "
      sInfo: "Showing <b>_START_ to _END_</b> of _TOTAL_ entries"
    iDisplayLength: 50

  $('#genres_wrapper .dataTables_filter input').addClass("input-medium");
  $('#genres_wrapper .dataTables_length select').addClass("select2-wrapper span12");

  $(".select2-wrapper").select2({minimumResultsForSearch: -1});
