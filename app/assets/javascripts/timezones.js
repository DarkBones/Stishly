$(document).on("turbolinks:load", () => {

  $(".timezone-on-focus").on("focusin", () => {
    $("#timezone_input").setTimezone();
  });

  $("#timezone_input").each(function(){
    $(this).setTimezone();
  });
  
});