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

}

function hideWeekday(){
  
}