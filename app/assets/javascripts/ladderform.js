/*$(".ladderform").change(function(e){
  alert("e");
  showHideFields($(e.target));
});

$("#simple_schedule_form").change(function(e){
  showHideFields($(e.target));
});*/

$(document).on("turbolinks:load", () => {
  addLadderformListeners();
});

function addLadderformListeners(){
  $(".ladderform").change(function(e){
    showHideFields($(e.target));
  });
}

function showHideFields($target) {
  var children;
  var selectedValue;

  if ($target.is("select")) {
    selectedValue = $target.val();
    $target.children("option").each(function(){

      if ($(this).attr("value") === selectedValue) {
        children = $(this).attr("children");
      }
    });

    if(typeof(children) !== "undefined"){
      if(children.length > 0){
        $target.next(".children").children(children).slideDown("fast");
      }
      $target.next(".children").children().not(children).slideUp("fast");
    }
  }
}

$(".pos_n").change(function(e){
  if($(e.target).val() <= 0){
    $(e.target).val(1);
  }
});