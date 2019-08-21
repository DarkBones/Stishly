window.setDeleteConfirmTargets = function() {
	$(".delete-confirm").each(function(){
		$(this).attr("data-toggle", "modal");
		$(this).attr("data-target", "#confirmation_modal");
		$(this).attr("data-link", $(this).attr("href"));
		$(this).attr("href", "#");
	});
}

window.setDeleteListeners = function() {
	$(".delete-confirm").click(function(e) {
		e.preventDefault();

		var message = "Are you sure?";
		var messageAttr = $(this).attr("confirm-message");

		$("#confirmation_modal form").attr("action", $(this).attr("data-link"));
		$("#confirmation_modal input[type='submit']").removeAttr("disabled");

		if(typeof(messageAttr) !== "undefined") {
			message = messageAttr;
		}
		$("#confirmation_modal p").text(message);
	});

	setDeleteConfirmTargets();
}

$(document).on("turbolinks:load", () => {
	setDeleteListeners();
	//setDeleteConfirmTargets();

	$("#confirmation_modal").on("show.bs.modal", function() {
    console.log("hh");
    console.log($(this).attr("id"));
  });

});