Dropzone.autoDiscover = false;

jQuery ->
  $(".dropzone").each ->
    $(this).dropzone
      url: $(this).data("url")
