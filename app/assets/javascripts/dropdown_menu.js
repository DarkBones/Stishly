function handleSearchResult(li, text) {
  if (li.attr("path").toUpperCase().indexOf(text) === -1) {
    li.hide();
  } else {
    li.show();

    if (li.text().toUpperCase().indexOf(text) === -1) {
      li.addClass("grey-out");
    } else {
      li.removeClass("grey-out");
    }
  }
}

function searchCategories(target, input){
  var $categories = $(target);
  var text = $(input).val();
  var liArr, liLength, li;
  var liPos = 0;

  if (typeof(text) === "undefined") {
    return;
  }

  text = text.toUpperCase();

  liArr = $categories.find("li").toArray();
  liLength = liArr.length;

  while (liPos < liLength) {
    li = $(liArr.pop());

    handleSearchResult(li, text);

    liPos += 1;
  }
}

$(document).on("click", ".dropdown", (event) => {
  $(event.target).next(".dropdown__options").show();
  $(event.target).next(".dropdown__options").find("#search-categories").focus();
  event.stopPropagation();

});

$(document).on("click", ".dropdown__options li", (event) => {
  $(event.target).closest(".dropdown__options").siblings(".dropdown__selected").html($(event.target).html());
  $(event.target).closest(".dropdown__options").hide();
  $(event.target).closest(".dropdown").next("input").val($(event.target).attr("class").split("_")[1]);
});

$(document).on("keyup", "#search-categories", (event) => {
  searchCategories($(event.target).closest(".dropdown__options"), $(event.target).val(), event);
});

$(document).on("click", (event) => {
  $(".dropdown__options").hide();
});

function setCategory(obj, id) {
  $categoriesDropdown = $(obj).closest("div#categoriesDropdownOptions").siblings("button#categories-dropdown");

  $categoriesDropdown.html($("#categoriesDropdownOptions li.category_" + id.toString()).html());
  $($categoriesDropdown.attr("input-target")).val(id);
}
