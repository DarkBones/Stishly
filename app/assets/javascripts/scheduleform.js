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