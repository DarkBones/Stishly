$(document).on("turbolinks:load", () => {
  addLadderformListeners();
  $(".ladderform").each(function(){
    showHideInitialfields($(this));
  });
});


// show the correct fields in case the user navigates to a different website and then click the back button in the browser
function showHideInitialfields($target){
  $target.find("select").each(function(){
    showHideFields($(this));
  });
  $target.find(".active[children]").each(function(){
    showHideFields($(this));
  });
}

addLadderformListeners();

function addLadderformListeners(){
  $(".ladderform").change(function(e){
    showHideFields($(e.target));
  });
  $(".ladderform").each(function(){
    showHideInitialfields($(this));
  });
}

function showHideFields($target) {
  var $children, children;

  $children = findLadderChildren($target);

  if ( $target.is("select") ){
    let selectedValue = $target.val();
    $target.children("option").each(function(){
      if ($(this).attr("value") === selectedValue) {
        children = $(this).attr("children");
      }
    });
  } else {
    children = $target.attr("children");
  }

  if ( typeof(children) === "undefined" ) {
    return;
  }

  if (children.length > 0) {
    $children.children(children).slideDown("fast");
  }
  $children.children().not(children).slideUp("fast");

}

function findLadderChildren($target) {
  if ( $target.is("[children-id]") ) {
    return $target.parents("#ladder-root").find("#" + $target.attr("children-id"));
  } else if ( $target.parents(".parent").is("[children-id]")) {
    return $("#" + $target.parents(".parent").attr("children-id"));
  } else if ( $target.next(".children").length > 0 ) {
    return $target.next(".children");
  } else {
    return $target.parents(".parent").next("children");
  }
}

window.setCurrencyListeners = function() {
  $("select.currency").change(function(e){
    $(e.target).attr("changed", true);
  });
}

$(".pos_n").change(function(e){
  if($(e.target).val() <= 0){
    $(e.target).val(1);
  }
});