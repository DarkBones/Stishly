var spinnerHtml;

$(document).on("turbolinks:load", () => {
  spinnerHtml = $("#ajax_spinner_template").html();
});