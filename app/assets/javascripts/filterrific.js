/*$(document).on('turbolinks:load', ()=> {
  var values = [];

  function flushResults() {
    console.log("FLUSHING");

    $("#filterrific_results").html("");
  }

  var $textInputs = $("#filterrific_filter input[type=text]");
  $textInputs.each(function(){
    values.push($(this).val());
    $(this).keyup(function() {
      flushResults();
    });
  });

  console.log(values);

});*/

$(document).on('turbolinks:load', ()=> {

  var $textFields = $("#filterrific_filter input[type=text]");
  var $selectFields = $("#filterrific_filter select");
  var $checkboxFields = $("#filterrific_filter input[type=checkbox]");

  function getValues() {
    vals = []
    $textFields.each(function(){
      vals.push($(this).val());
    });
    return vals
  }

  var values = getValues();

  function valuesChanged(){
    new_vals = getValues();

    new_v = ""
    while (typeof(new_v) !== "undefined") {
      new_v = new_vals.pop();
      old_v = values.pop();

      console.log(new_v + " !== " + old_v);

      if (new_v !== old_v) {
        values = getValues();
        return true
      }
    }

    values = getValues();
    return false
  }

  function flushResults() {
    console.log("FLUSHING");
    $("#filterrific_results").html("");
  }

  $textFields.each(function(){
    $(this).keyup(function() {
      console.log("KEYUP");
      if (valuesChanged()){
        flushResults();
      }
    });
  });

  $selectFields.each(function(){
    $(this).change(function() {
      flushResults();
    });
  });

  $checkboxFields.each(function(){
    $(this).change(function() {
      flushResults();
    });
  });

});