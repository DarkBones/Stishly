document.addEventListener("turbolinks:load", function() {

  $("#accounts_list").sortable({
    cancel: ".no-sorting",
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