Dropzone.autoDiscover = false;

jQuery ->
  $("#photos.dropzone").each ->
    $(this).dropzone
      url: $(this).data("url")

  $("#songs.dropzone").each ->
    $(this).dropzone
      url: $(this).data("url")
