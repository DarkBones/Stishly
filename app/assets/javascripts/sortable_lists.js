function makeSortableLists(className=".sortable-list", handleName=".sort-handle"){
  $(className).sortable({
    cancel: ".no-sorting",
    handle: handleName,
    delay: 150,
    update: function(e, ui) {
      Rails.ajax({
        url: "/accounts/sort",
        type: "PATCH",
        data: $(this).sortable("serialize"),
      });
    }
  });
}

$(document).on("turbolinks:load", ()=> {
  makeSortableLists();
});
