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
			} else {
				$("#category_delete_modal").modal("show");
			}
		}
	});
}
