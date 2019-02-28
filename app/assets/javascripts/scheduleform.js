function changeSchedulePeriod(selectObject) {
  var val = ""

  val = selectObject.value;

  switch (val.toLowerCase()) {
    case 'weekday':
      showWeekday();
      break;
    default:
      hideWeekday();
      $('#scheduleform p#period').text(val);
  }
}

function showWeekday(){
  $('#scheduleform #simple-period').hide();
  $('#scheduleform #weekday').show();
}

function hideWeekday(){
  $('#scheduleform #simple-period').show();
  $('#scheduleform #weekday').hide();
}

function advancedScheduleOptions(){
  var $advancedOptions = $("#scheduleform #schedule_advanced");
  var $advancedOptionsToggle = $("#scheduleform #schedule_advanced_toggle");

  if ($advancedOptions.is(":visible")){
    $advancedOptions.slideUp(200);
    $advancedOptionsToggle.text('show advanced options');
  } else {
    $advancedOptions.slideDown(200);
    $advancedOptionsToggle.text('hide advanced options');
  }
}