function deleteCategory(id) {
	$.ajax({
		type: "DELETE",
		url: "api/v1/categories/" + id + "/delete",
		success() {
			location.reload();
		}
	});
}

function prepareDeleteCategory(id) {
	$.ajax({
		type: "GET",
		dataType: "text",
		url: "api/v1/categories/" + id + "/transaction_count",
		success(data) {
			if (data === "0") {
				deleteCategory(id);
			} else if (data === "1") {
				triggerNotice("Cannot delete this category as there is 1 transaction associated with it.", true);
			} else {
				triggerNotice("Cannot delete this category as there are " + data + " transactions associated with it.", true);
			}
		}
	});
}
