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
				triggerNotice("<%= t('views.categories.delete.errors.single') %>", true);
			} else {
				triggerNotice("<%= t('views.categories.delete.errors.plural') %>".replace("@amount@", data.toString()), true);
			}
		}
	});
}
