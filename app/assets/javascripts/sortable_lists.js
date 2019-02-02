$(document).on('turbolinks:load', ()=> {
  makeSortableLists();
});

function makeSortableLists(class_name='.sortable-list', handle_name='.sort-handle'){
  $(class_name).sortable({
    cancel: '.no-sorting',
    handle: handle_name,
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: '/accounts/sort',
        type: 'PATCH',
        data: $(this).sortable('serialize'),
      });
    }
  });
}