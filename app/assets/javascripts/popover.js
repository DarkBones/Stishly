function setPopovers() {
	$(function () {
    $('[data-toggle="popover"]').popover()
  })
}

$(document).on("turbolinks:load", () => {
  setPopovers();
});