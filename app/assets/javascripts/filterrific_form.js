var submitted = false;

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

  function setSlider() {
    var slider;
    slider = new Slider('#filter-form #filterrific_amount_range', {tooltip: 'hover'});
  }

  // converts the amount range to subunits before submitting the form
  $("#filter-form").submit(function(e){
    var $inputTarget = $("#filter-form #filterrific_amount_range");
    var input = $inputTarget.val();
    var subunits, from, to;

    if (submitted) {
      return true;
    }

    e.preventDefault();

    if (input.match(/^\d+,\d+$/)){
      $.ajax({
        type: "GET",
        dataType: "json",
        url: "/api/user_currency/detailed",
        success(data) {
          submitted = true;

          subunits = data.subunit_to_unit;

          from = parseInt(input.split(",")[0]) * subunits;
          to = parseInt(input.split(",")[1]) * subunits;

          $inputTarget.val(from + "," + to);
          $("#filter-form").submit();
        }
      });
    }
  });

  setDropdownButtonHtml();
  setSlider();

});