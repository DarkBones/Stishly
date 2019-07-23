var spinnerHtml;

$(document).on("turbolinks:load", () => {
  spinnerHtml = $("#ajax_spinner_template").html();
});

function insertAjaxSpinner($target, size=75) {
	$target.prepend(spinnerHtml);
	$target.find(".ajax_spinner img").css("height", size.toString() + "px");
	$target.find(".ajax_spinner").show();
}

function removeAjaxSpinner($target) {
	$target.find(".ajax_spinner").remove();
}