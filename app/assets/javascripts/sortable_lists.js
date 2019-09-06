function makeSortableLists(className=".sortable-list", handleName=".sort-handle"){
  $(className).sortable({
    cancel: ".no-sorting",
    handle: handleName,
    delay: 150,
    update(e, ui) {
      Rails.ajax({
        url: "/accounts/sort",
        type: "PATCH",
        //data: $(this).sortable("serialize"),
        data: serializeHashed($(this)),
      });
    }
  });
}

$(document).on("turbolinks:load", () => {
  makeSortableLists();
});
