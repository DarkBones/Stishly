function changeSchedulePeriod(selectObject) {
  var val = "";

  val = selectObject.value;

  switch (val.toLowerCase()) {
    case 'daily':
      $('#scheduleform p#period').text('Days');
      break;
    case 'weekly':
      $('#scheduleform p#period').text('Weeks');
      break;
    case 'monthly':
      $('#scheduleform p#period').text('Months');
      break;
    case 'annually':
      $('#scheduleform p#period').text('Years');
      break;
    default:
      //hideWeekday();
      $('#scheduleform p#period').text('');
  }
}

function changeScheduleExclusionMet(selectObject){
  var val = "";
  var $exlusionMet2 = $('#scheduleform #schedule_exclusion_met2');

  val = selectObject.value;

  switch (val.toLowerCase()) {
    case 'don\'t run':
      $exlusionMet2.hide();
      break;
    default:
      $exlusionMet2.show();
  }
}

function changeScheduleDays(selectObject){
  var val = "";
  var $scheduleDays2 = $('#scheduleform #schedule_days2');

  val = selectObject.value;

  switch (val.toLowerCase()) {
    case 'specific dates':
      showDaypicker();
      $scheduleDays2.hide();
      break;
    default:
      hideDaypicker();
      $scheduleDays2.show();
  }
}

function showDaypicker(){
  var $daypicker = $("#scheduleform #daypicker");
  var $daypickerExclude = $("#scheduleform #daypicker-exclude");
  var $weekdayExclude = $("#scheduleform #weekday-exclude");

  $daypicker.show();
  $daypickerExclude.hide();
  $weekdayExclude.show();
}
function hideDaypicker(){
  var $daypicker = $("#scheduleform #daypicker");
  var $daypickerExclude = $("#scheduleform #daypicker-exclude");
  var $weekdayExclude = $("#scheduleform #weekday-exclude");

  $daypicker.hide();
  $daypickerExclude.show();
  $weekdayExclude.hide();
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

function schedulePickDate(date, $datesPicked) {
  var is_active = false;
  //var $datesPicked = $('#scheduleform #schedule_dates_picked');
  var dates = $datesPicked.val().split(' ');
  var index = -1;
  var value = $(date).text();

  $(date).toggleClass('active');
  is_active = $(date).hasClass('active');

  if (is_active) {
    dates.push(value);
  } else {
    index = dates.indexOf(value);
    if (index > -1) {
      dates.splice(index, 1);
    }
  }
  //dates = dates.replace(/ +(?= )/g,'');
  console.log(dates);
  $datesPicked.val(dates.join(' '));
}

function resetScheduleMenu(){

}