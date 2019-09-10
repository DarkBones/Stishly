function makeSortableLists(className=".sortable-list", handleName=".sort-handle"){
  $(className).sortable({
    cancel: ".no-sorting",
    handle: handleName,
    delay: 150,
    update(e, ui) {
      Rails.ajax({
        url: "/accounts/sort",
        type: "PATCH",
        data: serializeHashed($(this)),
      });
    }
  });

  $(".sortable-nested").nestedSortable({
    listType: "ul",
    startCollapsed: true,
    handle: "div",
    items: "li",
    //toleranceElement: "> div"
    update(e, ui) {
      console.log(serializeHashedNested($(this)));
      Rails.ajax({
        url: "/categories/sort",
        type: "PATCH",
        data: serializeHashedNested($(this)),
      });
    }
  });
}

$(document).on("turbolinks:load", () => {
  makeSortableLists();
});
