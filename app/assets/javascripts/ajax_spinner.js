var spinnerHtml;

$(document).on("turbolinks:load", () => {
	spinnerHtml = $("#ajax_spinner_template").html();

	$(function() {

		window.insertAjaxSpinner = function($target, size=75) {
			if ($target.find(".ajax_spinner").length === 0){
				$target.prepend(spinnerHtml);
				$target.find(".ajax_spinner img").css("height", size.toString() + "px");
				$target.find(".ajax_spinner").show();
			}
		};
		window.removeAjaxSpinner = function($target) {
			$target.find(".ajax_spinner").remove();
		};

	});
});