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
    $parent.fadeOut(2000);
  }, 1000);
}

function remove_notice(id) {
  $(id).parent().closest('div').remove();
}

function remove_active_notices() {
  if ($('#flash_notice').length) {
    remove_notice('#flash_notice');
  }

  if ($('#flash_alert').length) {
    remove_notice('#flash_alert');
  }
}

function trigger_notice (text, is_error) {
  remove_active_notices();
  
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