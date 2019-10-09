function readNotifications() {
	$.ajax({
		type: "PATCH",
		url: "/api/v1/notifications/mark_as_read"
	});
}