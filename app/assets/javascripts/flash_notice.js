function hideTimeout(id) {
  var $parent = $(id).parent().closest("div");
  setTimeout( function() {
    $parent.fadeOut(2000);
  }, 1000);
}

$(document).on("turbolinks:load", () => {
  if ($("#flash_notice").length) {
    hideTimeout("#flash_notice");
  }

  if ($("#flash_alert").length) {
    hideTimeout("#flash_alert");
  }

});

function removeNotice(id) {
  $(id).parent().closest("div").remove();
}

function removeActiveNotices() {
  if ($("#flash_notice").length) {
    removeNotice("#flash_notice");
  }

  if ($("#flash_alert").length) {
    removeNotice("#flash_alert");
  }
}

function triggerNotice (text, isError) {
  removeActiveNotices();
  
  var classes = "alert alert-dismissible";
  var id = "flash_";

  if (isError) {
    classes += " alert-danger";
    id += "alert";
  } else {
    classes += " alert-success";
    id += "notice";
  }

  var alertHtml = "<div class=\"" + classes + "\"><div id=\"" + id + "\">" + text + "</div></div>";

  $("main").prepend(alertHtml);

  hideTimeout("#" + id);
}