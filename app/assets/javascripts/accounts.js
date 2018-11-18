document.addEventListener("turbolinks:load", function() {

  $("#accounts_list").sortable({
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