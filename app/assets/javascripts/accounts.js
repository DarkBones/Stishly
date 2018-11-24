$(document).on('turbolinks:load', ()=> {
  makeSortableLists();
  //$('#left-menu').disableSelection();

  $('#create-account-button').on('click', () => {
    $('#create-account-form').slideToggle(100);
    $("#account_name_balance").focus();
  });

  $('#cancel-account').on('click', () => {
    $('#create-account-form').slideUp(100);
    $("#account_name_balance").val("");
  });

  $('.account-button').on('click', (event) => {
    window.location.href = '/' + event.target.id.replace('_', '/');
  });
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