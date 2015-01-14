// JS for price_low, price_high attr in prices index filter

function getSuffix(value){
  switch (value) {
    case 'greater than':
       suffix = '_gt';
      break;
    case 'lower than':
       suffix = '_lt';
      break;
    case 'equals':
      suffix = '_eq';
      break;
    default:
      suffix = '';
  }
  return suffix ;
}

$(document).ready(function(){

  $('#js_select_price_low').change(function(){
    chosenOption = $(this).val();
    newID = 'q[price_low' + getSuffix(chosenOption) + ']';
    $('#price_low input').attr('name', newID);
  })

  $('#js_select_price_high').change(function(){
    chosenOption = $(this).val();
    newID = 'q[price_high' + getSuffix(chosenOption) + ']';
    $('#price_high input').attr('name', newID);
  })
})