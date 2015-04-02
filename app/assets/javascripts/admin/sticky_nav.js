$(document).ready(function(){
  var stickButton = $('[data-toggle-pin="sidebar"]')
  stickButton.click(function(){
    // true if want to stick
    var action = $('body').hasClass('menu-pin') ? 'unstick' : 'stick';
    // url for session action
    var url = $(this).data('url');
    // post request to session action
    $.post(url, {stick_action: action});
  });
});
