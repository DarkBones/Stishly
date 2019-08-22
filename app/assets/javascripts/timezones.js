//= require jquery.detect_timezone

$(document).on("turbolinks:load", () => {

  $(".timezone-on-focus").on("focusin", () => {
    $("#timezone_input").setTimezone();
  });

  setTimezones();
  
});