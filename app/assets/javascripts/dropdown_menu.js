function searchCategories(target, input){
  var $categories = $(target);
  var text = $(input).val();
  var li, i;

  li = $categories.find("li");
  for (let i = 0; i < li.length; i++){

    if (li[i].innerText.toUpperCase().indexOf(text.toUpperCase()) !== -1) {
      li[i].style.display = "";
    } else {
      li[i].style.display = "none";
    }
  }
}

$(document).on("click", ".dropdown", (event) => {
  $(event.target).next(".dropdown__options").show();
  $(event.target).next(".dropdown__options").find("#search-categories").focus();
  event.stopPropagation();

});

$(document).on("click", ".dropdown__options li", (event)=> {
  $(event.target).closest(".dropdown__options").siblings(".dropdown__selected").html($(event.target).html());
  $(event.target).closest(".dropdown__options").hide();
  $(event.target).closest(".dropdown").next("input").val($(event.target).attr("class").split("_")[1]);
});

$(document).on("keyup", "#search-categories", (event)=> {
  searchCategories($(event.target).closest(".dropdown__options"), $(event.target).val(), event);
});

$(document).on("click", (event) => {
  $(".dropdown__options").hide();
});

function setCategory(id) {
  $("button#categories-dropdown").html($("#categoriesDropdownOptions li.category_" + id.toString()).html());
  $($("button#categories-dropdown").attr("input-target")).val(id);
}
