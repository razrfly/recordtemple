// JS FILE FOR BOTH BACKEND AND FRONTEND

function initInputs(){
  currentHigh = $('.' + $('.js_select_price.high').val(), '#price_high');
  currentLow = $('.' + $('.js_select_price.low').val(), '#price_low');
  populateValueWith(currentHigh);
  populateValueWith(currentLow);
  disableInputsExcept($('.js_select_price.high'));
  disableInputsExcept($('.js_select_price.low'));
}

function populateValueWith(obj){
  $('.price', obj.parent().parent()).val(obj.val());
}

function disableInputsExcept(obj){
  selectedInput = $('.' + obj.val(), obj.parent().parent());
  $('.price', obj.parent().parent()).not(selectedInput)
    .prop('disabled', true)
    .hide();
  selectedInput
    .prop('disabled', false)
    .show();
}

$(document).ready(function(){

  initInputs();

  $('.js_select_price').change(function(){
    disableInputsExcept($(this));
  });

  $('#price_high .price, #price_low .price').change(function(){
    populateValueWith($(this));
  });

});
