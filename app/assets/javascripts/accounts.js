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
    link_name = event.currentTarget.closest('.account-button').getAttribute('name')
    console.log('/' + link_name.replace('_', '/'));
    window.location.href = '/' + link_name.replace('_', '/');
  });

  $('#account_name_balance').attr('maxlength',23);

  // don't allow dots in input field
  $('#account_account_string').keyup(function(e){
    if (e.which == 190){
      $('#account_account_string').val($('#account_account_string').val().replace(".", ""));
    }
  });

  $('#timezone_input').set_timezone();
});

function makeSortableLists(class_name='.sortable-list', handle_name='.sort-handle'){
  $(class_name).sortable({
    cancel: '.no-sorting',
    handle: handle_name,
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: '/account/sort',
        type: 'PATCH',
        data: $(this).sortable('serialize'),
      });
    }
  });
}