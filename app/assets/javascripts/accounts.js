$(document).on('turbolinks:load', ()=> {
  makeSortableLists();
  //$('#left-menu').disableSelection();

  $('#create-account-button').on('click', () => {
    $('#create-account-form').slideToggle(100);
    $("#account_name_balance").focus();
  });

  $('#quick-transaction-input').focus();

  $('.timezone-on-focus').on('focusin', () => {
    $('#timezone_input').set_timezone();
  });

  $('#cancel-account').on('click', () => {
    $('#create-account-form').slideUp(100);
    $("#account_name_balance").val("");
  });

  $('.account-button').on('click', (event) => {
    window.location.href = '/' + event.currentTarget.closest('.account-button').id.replace('_', '/');
  });

  $('#account_name_balance').attr('maxlength',23);

  $('#timezone_input').set_timezone();
});

function makeSortableLists(class_name='.sortable-list', handle_name='.sort-handle'){
  $(class_name).sortable({
    cancel: '.no-sorting',
    handle: handle_name,
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: $(this).data('url'),
        type: 'PATCH',
        data: $(this).sortable('serialize'),
      });
    }
  });
}