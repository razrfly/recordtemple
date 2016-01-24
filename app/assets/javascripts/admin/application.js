//= require jquery
//= require jquery_ujs

//  pages core deps
//= require pages_admin_template/plugins/pace/pace.min
//= require pages_admin_template/plugins/modernizr.custom
//= require pages_admin_template/plugins/jquery-ui/jquery-ui.min
//= require pages_admin_template/plugins/boostrapv3/js/bootstrap.min
//= require pages_admin_template/plugins/jquery/jquery-easy
//= require pages_admin_template/plugins/jquery-unveil/jquery.unveil.min
//= require pages_admin_template/plugins/jquery-bez/jquery.bez.min
//= require pages_admin_template/plugins/jquery-ios-list/jquery.ioslist.min
//= require pages_admin_template/plugins/imagesloaded/imagesloaded.pkgd.min
//= require pages_admin_template/plugins/jquery-actual/jquery.actual.min
//= require pages_admin_template/plugins/jquery-scrollbar/jquery.scrollbar.min
//
//  pages datatables deps
//= require pages_admin_template/plugins/bootstrap-select2/select2.min
//= require pages_admin_template/plugins/classie/classie
//= require pages_admin_template/plugins/switchery/js/switchery.min
//= require pages_admin_template/plugins/jquery-datatable/media/js/jquery.dataTables.min
//= require pages_admin_template/plugins/jquery-datatable/extensions/TableTools/js/dataTables.tableTools.min
//= require pages_admin_template/plugins/jquery-datatable/media/js/dataTables.bootstrap
//= require pages_admin_template/plugins/jquery-datatable/extensions/Bootstrap/jquery-datatable-bootstrap
//= require pages_admin_template/plugins/datatables-responsive/js/datatables.responsive
//= require pages_admin_template/plugins/datatables-responsive/js/lodash.min
//
//  pages image gallery deps (copied without checking)
//= require pages_admin_template/plugins/jquery-isotope/isotope.pkgd.min
//= require pages_admin_template/plugins/jquery-isotope/masonry-horizontal
//= require pages_admin_template/plugins/codrops-dialogFx/dialogFx
//
//  pages
//= require pages_admin_template/js/pages

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
