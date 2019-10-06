$(document).on("turbolinks:load", () => {
	$(function() {
		window.setDeleteConfirmTargets = function() {
			$(".delete-confirm").each(function(){
				if( $(this).is('[data-link]') === false ){
					$(this).attr("data-toggle", "modal");
					$(this).attr("data-target", "#confirmation_modal");
					$(this).attr("data-link", $(this).attr("href"));
					$(this).attr("href", "#");
				}
			});
		}
		window.setDeleteListeners = function() {
			$(".delete-confirm").click(function(e) {
				e.preventDefault();

				var message = "Are you sure?";
				var messageAttr = $(this).attr("confirm-message");

				var ids = "";
				var action = "";

				if(typeof($(this).attr("ids-target")) !== "undefined") {
					ids = $($(this).attr("ids-target")).val().replace(/ /g, ",");
				} else {
					$("#confirmation_modal #ids").val("");
				}

				action = $(this).attr("data-link");
				if (ids.length > 0) {
					action += "/" + ids;
				}

				$("#confirmation_modal form").attr("action", action);
				$("#confirmation_modal input[type='submit']").removeAttr("disabled");

				if(typeof(messageAttr) !== "undefined") {
					message = messageAttr;
				}
				$("#confirmation_modal p").text(message);
			});

			setDeleteConfirmTargets();
		};

	});
	setDeleteListeners();
});