$(document).on('turbolinks:load', ()=> {
  $('#quick-transaction-input').focus();

  $('#transactionmenu').show();

  if ($('#transaction_multiple_transactions').is(':checked')) {
    $('.transactions_menu_multiple').show();
    $('.transactions_menu_single').hide();
  } else{
    $('.transactions_menu_multiple').hide();
    $('.transactions_menu_single').show();
  }

  $('#transaction_multiple_transactions').change(function() {
    if($(this).is(":checked")) {
      $('.transactions_menu_multiple').show();
      $('.transactions_menu_single').hide();
    } else {
      $('.transactions_menu_multiple').hide();
      $('.transactions_menu_single').show();
    }
  });
});