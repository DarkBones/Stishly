var type = "simple"

function getScheduleNextOccurrences(){
  $("#scheduleform #next_occurrences").text("");
  //var type = ""
  var name = sanitize($("#scheduleform #schedule_name").val());
  var start_date = sanitize($("#scheduleform #schedule_start_date").val());
  var timezone = sanitize($("#scheduleform #timezone_input").val());
  var schedule = sanitize($("#scheduleform #schedule_schedule").val());
  var run_every = sanitize($("#scheduleform #schedule_run_every").val());
  var days = sanitize($("#scheduleform #schedule_days").val());
  var days2 = sanitize($("#scheduleform #schedule_days2").val());
  var dates_picked = sanitize($("#scheduleform #schedule_dates_picked").val());
  var weekday_mon = sanitize($("#scheduleform #schedule_weekday_mon").prop("checked")*1);
  var weekday_tue = sanitize($("#scheduleform #schedule_weekday_tue").prop("checked")*1);
  var weekday_wed = sanitize($("#scheduleform #schedule_weekday_wed").prop("checked")*1);
  var weekday_thu = sanitize($("#scheduleform #schedule_weekday_thu").prop("checked")*1);
  var weekday_fri = sanitize($("#scheduleform #schedule_weekday_fri").prop("checked")*1);
  var weekday_sat = sanitize($("#scheduleform #schedule_weekday_sat").prop("checked")*1);
  var weekday_sun = sanitize($("#scheduleform #schedule_weekday_sun").prop("checked")*1);
  var end_date = sanitize($("#scheduleform #schedule_end_date").val());
  var weekday_exclude_mon = sanitize($("#scheduleform #schedule_weekday_exclude_mon").prop("checked")*1);
  var weekday_exclude_tue = sanitize($("#scheduleform #schedule_weekday_exclude_tue").prop("checked")*1);
  var weekday_exclude_wed = sanitize($("#scheduleform #schedule_weekday_exclude_wed").prop("checked")*1);
  var weekday_exclude_thu = sanitize($("#scheduleform #schedule_weekday_exclude_thu").prop("checked")*1);
  var weekday_exclude_fri = sanitize($("#scheduleform #schedule_weekday_exclude_fri").prop("checked")*1);
  var weekday_exclude_sat = sanitize($("#scheduleform #schedule_weekday_exclude_sat").prop("checked")*1);
  var weekday_exclude_sun = sanitize($("#scheduleform #schedule_weekday_exclude_sun").prop("checked")*1);
  var dates_picked_exclude = sanitize($("#scheduleform #schedule_dates_picked_exclude").val());
  var exclusion_met1 = sanitize($("#scheduleform #schedule_exclusion_met1").val());
  var exclusion_met2 = sanitize($("#scheduleform #schedule_exclusion_met2").val());
  var occurrence_count = "10";

  url = "api/next_occurrences" + "/" + type + "/" + name + "/" + start_date + "/" + timezone + "/" + schedule + "/" + run_every + "/" + days + "/" + days2 + "/" + dates_picked + "/" + weekday_mon + "/" + weekday_tue + "/" + weekday_wed + "/" + weekday_thu + "/" + weekday_fri + "/" + weekday_sat + "/" + weekday_sun + "/" + end_date + "/" + weekday_exclude_mon + "/" + weekday_exclude_tue + "/" + weekday_exclude_wed + "/" + weekday_exclude_thu + "/" + weekday_exclude_fri + "/" + weekday_exclude_sat + "/" + weekday_exclude_sun + "/" + dates_picked_exclude + "/" + exclusion_met1 + "/" + exclusion_met2 + "/" + occurrence_count;

  $.ajax({
    type: "GET",
    dataType: "json",
    url: url,
    success: function(data) {
      $("#scheduleform #next_occurrences").html("<ul>")
      data.forEach(function(d) {
        $("#scheduleform #next_occurrences").append("<li>" + d + "</li>");
      })
      $("#scheduleform #next_occurrences").append("</ul>");
    }
  })
}

function sanitize(val) {
  val = val.toString();
  val = val.replace(/\//g, "%2F");
  if (val.length == 0) {
    val = "%20"
  }

  val = val.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');

  return val;
}

function changeSchedulePeriod(val) {
  switch (val.toLowerCase()) {
    case 'daily':
      $('#scheduleform p#period').text('Days');
      $('#scheduleform .daily').show();
      $('#scheduleform .weekly').hide();
      $('#scheduleform .monthly').hide();
      $('#scheduleform .annually').hide();
      break;
    case 'weekly':
      $('#scheduleform p#period').text('Weeks');
      $('#scheduleform .daily').hide();
      $('#scheduleform .weekly').show();
      $('#scheduleform .monthly').hide();
      $('#scheduleform .annually').hide();
      break;
    case 'monthly':
      $('#scheduleform p#period').text('Months');
      $('#scheduleform .daily').hide();
      $('#scheduleform .weekly').hide();
      $('#scheduleform .monthly').show();
      $('#scheduleform .annually').hide();
      break;
    case 'annually':
      $('#scheduleform p#period').text('Years');
      $('#scheduleform .daily').hide();
      $('#scheduleform .weekly').hide();
      $('#scheduleform .monthly').hide();
      $('#scheduleform .annually').show();
      break;
    default:
      //hideWeekday();
      $('#scheduleform p#period').text('');
  }
}

function changeScheduleExclusionMet(val){
  var $exlusionMet2 = $('#scheduleform #schedule_exclusion_met2');

  switch (val.toLowerCase()) {
    case 'cancel':
      $exlusionMet2.hide();
      break;
    default:
      $exlusionMet2.show();
  }
}

function changeScheduleDays(val){
  var $scheduleDays2 = $('#scheduleform #schedule_days2');
  var $daypickerExclude = $("#scheduleform #daypicker-exclude");
  var $weekdayExclude = $("#scheduleform #weekday-exclude");
  var $daypicker = $("#scheduleform #daypicker");

  switch (val.toLowerCase()) {
    case 'specific':
      showDaypicker();
      $scheduleDays2.hide();
      break;
    default:
      $daypicker.hide();
      $scheduleDays2.show();
      switch ($scheduleDays2.val()) {
        case 'day':
          $weekdayExclude.show();
          $daypickerExclude.hide();
          break;
        default:
          $weekdayExclude.hide();
          $daypickerExclude.show();
      }
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
  $('#scheduleform .schedule-simple-period').hide();
  $('#scheduleform #weekday').show();
}

function hideWeekday(){
  $('#scheduleform .schedule-simple-period').show();
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

  $datesPicked.val(dates.join(' '));

  getScheduleNextOccurrences()
}

function changeScheduleType(sType){
  type = sType
  if (sType == 'simple'){
    $('#scheduleform .schedule-advanced').hide();
  } else {
    $('#scheduleform .schedule-advanced').show();
  }
}

function resetScheduleMenu(){
  $('#scheduleform #schedule_schedule').val('monthly');
  changeSchedulePeriod('monthly');
  changeScheduleType('simple');
  changeScheduleDays('specific');
  changeScheduleExclusionMet('cancel');

  // update date & time
  $('#scheduleform #schedule_start_date').val(get_date());
  $('#scheduleform #schedule_start_time').val(get_time());
  $('#scheduleform #timezone_input').set_timezone();

  // reset the button-group elements
  $('#scheduleform #button-group').each(function(index){
    $(this).find('input').each(function(i){
      $(this).prop("checked", i==0)
    });
    $(this).find('label').each(function(i){
      if(i == 0){
        $(this).addClass('active');
      } else {
        $(this).removeClass('active');
      }
    });
  });

  getScheduleNextOccurrences()
}
