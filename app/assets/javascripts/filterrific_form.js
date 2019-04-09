$(document).on('turbolinks:load', ()=> {

  function setDropdownButtonHtml() {
    var cat_id, $button, $dropdownOption;

    cat_id = $("#filter-form #filterrific_category_id").val();

    $button = $("#filter-form #categories-dropdown");

    $dropdownOption = $("#filter-form #categoriesDropdownOptions li.category_" + cat_id)
    if (typeof($dropdownOption) !== "undefined") {
      $button.html($dropdownOption.html());
    }
  }

  setDropdownButtonHtml();

});