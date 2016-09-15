jQuery ->
  $('.ezdz-image-uploader').each (index) ->
    $(this).find('[type="file"]').ezdz
      text: '<i class="fa fa-picture-o"></i>'
    uploaderName = $(this).find('input.attachment').attr("name")
    imageUrl = $(this).data('image-url') || null
    if imageUrl
      $('[type="file"][name="' + uploaderName + '"]').ezdz "preview", imageUrl
