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
    handle: ".sort-handle",
    helper: 'clone',
    items: "li",
    opacity: .6,
    isTree: true,
    toleranceElement: "> div",
    update(e, ui) {
      if ($(this).attr("id") === "categories_list") {
        setCategoryColors($(this));
      }
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