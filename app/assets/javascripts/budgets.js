function insertNewBudget() {
	alert("insert new budget");
}

$(document).on("turbolinks:load", () => {
	$("button#new-budget").click(function(){
		insertNewBudget();
	});
});