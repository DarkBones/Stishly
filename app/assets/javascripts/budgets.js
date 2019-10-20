function insertNewBudget() {
	$("#new-budget-form").slideToggle(200);
}

function showBudgetDetails(id) {
	$(".budget-row").each(function(){
		$(this).slideUp(200);
		$(this).find(".budget-edit-button").show();
		$(this).find(".budget-edit-form").hide();
	});

	if ($("#budget_" + id).is(":visible")) {
		$("#budget_" + id).slideUp(200);
	} else {
		$("#budget_" + id).slideDown(200);
	}
}

function showBudgetEditForm(obj) {
  $(obj).hide();
  $(obj).next(".budget-edit-form").slideDown();
}

$(document).on("turbolinks:load", () => {
	$("button#new-budget").click(function(){
		insertNewBudget();
	});
});