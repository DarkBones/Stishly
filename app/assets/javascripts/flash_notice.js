$(document).on('turbolinks:load', ()=> {
  if ($('#flash_notice').length) {
    hideTimeout('#flash_notice');
  }

  if ($('#flash_alert').length) {
    hideTimeout('#flash_alert');
  }

});

function hideTimeout(id) {
  $parent = $(id).parent().closest('div');
  setTimeout( function() {
    $parent.fadeOut(200);
  }, 4000);

  /*setTimeout( function() {
    $parent.remove();
  }, 5000);*/
}

function trigger_notice (text, is_error) {
  var classes = "alert alert-dismissible";
  var id = "flash_";

  if (is_error) {
    classes += " alert-danger";
    id += "alert";
  } else {
    classes += " alert-success";
    id += "notice";
  }

  var alert_html = '<div class="' + classes + '""><div id="' + id + '">' + text + '</div></div>'

  $('main').prepend(alert_html);

  hideTimeout('#' + id);
}