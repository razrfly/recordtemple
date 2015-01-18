function setZoom(){
  $('.cover-photo.medium').magnify({
    speed: 200,
    src: $('.cover-photo.medium').data('img-large')
  });
}

function updateZoom(newURL){
  $('.magnify-lens').css('background-image', 'url('+ newURL +')');
}

function replaceImages(small, medium){
  $('#covers .active').removeClass('active');
  small.addClass('active');
  $(medium).animate({opacity: 0.8}, 250, function(){
    medium.data('img', small.data('img-medium'));
    medium.data('img-large', small.data('img-large'));
    medium.css('background-image', 'url('+ medium.data('img') +')');
    updateZoom(medium.data('img-large'));
    $(this).animate({opacity: 1}, 250)
  });
}

function loadImages(){
  $('.cover-photo').each(function(){
    $(this).css('background-image', 'url('+ $(this).data('img') +')');
  });
  setZoom();
}

$('.cover-photo').not('cover-photo.medium').click(function(){
  replaceImages($(this), $('.cover-photo.medium'));
});

$(document).ready(function(){
  loadImages();
});