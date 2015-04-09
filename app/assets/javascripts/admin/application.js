//= require jquery
//= require jquery_ujs

//= require pages-admin-template

//= require selectize
//= require soundmanager2
//= require soundmanager2/bar-ui
//= require bootstrap-markdown-bundle

//= require ./jquery.magnify
//= require ./prices
//= require ./selectize
//= require ./soundmanager
//= require ./sticky_nav
//= require ./sortable
//= require ./pages
//= require ./markdown



// -- resize two blocks to the same height (the highest one) --
function resizeBlocks(block1, block2){
  ($(block1).height() > $(block2).height()) ? $(block2).height($(block1).height()) : $(block1).height($(block2).height());
}
