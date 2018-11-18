document.addEventListener("turbolinks:load", function() {

  $(".sortable-list").sortable({
    cancel: ".no-sorting",
    handle: ".sort-handle",
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: $(this).sortable('serialize'),
      });
    }
  });
  $("#accounts_list").disableSelection();

});