window.setPopovers = function() {
	$(function () {
    $("[data-toggle='popover']").popover();
  })
};

$(document).on("turbolinks:load", () => {
  setPopovers();
});