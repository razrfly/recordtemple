//= require jquery
//= require jquery_ujs

//= require selectize
//= require soundmanager2
//= require soundmanager2/bar-ui
//= require owl.carousel
//= require twitter/typeahead.min

//= require ./searches
//= require_tree ./refills



$(document).ready(function() {
  $("#owl-carousel").owlCarousel({
    autoPlay: 3000, //Set AutoPlay to 3 seconds
    items: 4,
    itemsDesktop: [1199,3],
    itemsDesktopSmall: [979,3],
    pagination: false

  });
});