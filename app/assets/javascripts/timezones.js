//= require jquery.detect_timezone

$(document).on("turbolinks:load", () => {

  $(".timezone-on-focus").on("focusin", () => {
    $("#timezone_input").setTimezone();
  });

  setTimezones();
  
});

window.setTimezones = function() {
	$("#timezone_input").each(function(){
    $(this).setTimezone();
  });
}