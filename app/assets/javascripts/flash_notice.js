function hideTimeout(id) {
  var hov = 0;
  var $parent = $(id).parent().closest("div");
  $parent.hover(function(){
    clearTimeout();
    $parent.stop(true, true).fadeOut();
    $parent.fadeIn(1);
    hov = 1;
  }, function(){
    hov = 0;
    setTimeout(function(){
      if(hov === 0) {
        $parent.fadeOut(2000);
      }
    }, 1000);
  });
}

$(document).on("turbolinks:load", () => {
  if ($("#flash_notice").length) {
    hideTimeout("#flash_notice");
  }

  if ($("#flash_alert").length) {
    hideTimeout("#flash_alert");
  }

  $("#flash_notice").hover(function(){
    hideTimeout("#flash_alert");
  });

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