$(document).on('turbolinks:load', ()=> {
  $('#quick-transaction-input').focus();

  $('#transactionmenu').show();

  $('.transactions_menu_multiple_accounts').hide();

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

  $('#transaction_type').change(function() {
    if($(this).val().toLowerCase() == 'transfer'){
      $('.transactions_menu_multiple_accounts').show();
      $('.transactions_menu_single_account').hide();
    } else {
      $('.transactions_menu_multiple_accounts').hide();
      $('.transactions_menu_single_account').show();
    }
  });
});