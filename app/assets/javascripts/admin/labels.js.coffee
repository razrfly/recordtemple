jQuery ->
  $("table#labels").dataTable
    sDom: "<'row'<'col-md-6'l><'col-md-6'f>r>t<'row'<'col-md-12'p i>>"
    aaSorting: []
    oLanguage:
      sLengthMenu: "_MENU_ "
      sInfo: "Showing <b>_START_ to _END_</b> of _TOTAL_ entries"
    iDisplayLength: 50
    bJQueryUI: true
    bServerSide: true
    sAjaxSource: $('table#labels').data('source')
    aoColumnDefs: [
      {bSortable: false, aTargets: [1, 2]}
    ]

  $('#labels_wrapper .dataTables_filter input').addClass("input-medium");
  $('#labels_wrapper .dataTables_length select').addClass("select2-wrapper span12");

  $("table#label-records").dataTable
    sDom: "<'row'<'col-md-6'l><'col-md-6'f>r>t<'row'<'col-md-12'p i>>"
    aaSorting: []
    oLanguage:
      sLengthMenu: "_MENU_ "
      sInfo: "Showing <b>_START_ to _END_</b> of _TOTAL_ entries"
    iDisplayLength: 50

  $('#label-records_wrapper .dataTables_filter input').addClass("input-medium");
  $('#label-records_wrapper .dataTables_length select').addClass("select2-wrapper span12");

  $(".select2-wrapper").select2({minimumResultsForSearch: -1});
