var type = "simple";

function sanitize(val) {
  val = val.toString();
  val = val.replace(/\//g, "%2F");
  if (val.length === 0) {
    val = "%20"
  }

  val = val.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');

  return val;
}

function getScheduleNextOccurrences(){

  $("#scheduleform #next_occurrences").text("");
  //var type = ""
  var name = sanitize($("#scheduleform #schedule_name").val());
  var startDate = sanitize($("#scheduleform #schedule_start_date").val());
  var timezone = sanitize($("#scheduleform #timezone_input").val());
  var schedule = sanitize($("#scheduleform #schedule_schedule").val());
  var runEvery = sanitize($("#scheduleform #schedule_run_every").val());
  var days = sanitize($("#scheduleform #schedule_days").val());
  var days2 = sanitize($("#scheduleform #schedule_days2").val());
  var datesPicked = sanitize($("#scheduleform #schedule_dates_picked").val());
  var weekdayMon = sanitize($("#scheduleform #schedule_weekday_mon").prop("checked")*1);
  var weekdayTue = sanitize($("#scheduleform #schedule_weekday_tue").prop("checked")*1);
  var weekdayWed = sanitize($("#scheduleform #schedule_weekday_wed").prop("checked")*1);
  var weekdayThu = sanitize($("#scheduleform #schedule_weekday_thu").prop("checked")*1);
  var weekdayFri = sanitize($("#scheduleform #schedule_weekday_fri").prop("checked")*1);
  var weekdaySat = sanitize($("#scheduleform #schedule_weekday_sat").prop("checked")*1);
  var weekdaySun = sanitize($("#scheduleform #schedule_weekday_sun").prop("checked")*1);
  var endDate = sanitize($("#scheduleform #schedule_end_date").val());
  var weekdayExcludeMon = sanitize($("#scheduleform #schedule_weekday_exclude_mon").prop("checked")*1);
  var weekdayExcludeTue = sanitize($("#scheduleform #schedule_weekday_exclude_tue").prop("checked")*1);
  var weekdayExcludeWed = sanitize($("#scheduleform #schedule_weekday_exclude_wed").prop("checked")*1);
  var weekdayExcludeThu = sanitize($("#scheduleform #schedule_weekday_exclude_thu").prop("checked")*1);
  var weekdayExcludeFri = sanitize($("#scheduleform #schedule_weekday_exclude_fri").prop("checked")*1);
  var weekdayExcludeSat = sanitize($("#scheduleform #schedule_weekday_exclude_sat").prop("checked")*1);
  var weekdayExcludeSun = sanitize($("#scheduleform #schedule_weekday_exclude_sun").prop("checked")*1);
  var datesPickedExclude = sanitize($("#scheduleform #schedule_dates_picked_exclude").val());
  var exclusionMet1 = sanitize($("#scheduleform #schedule_exclusion_met1").val());
  var exclusionMet2 = sanitize($("#scheduleform #schedule_exclusion_met2").val());
  var occurrenceCount = "10";

  url = "api/next_occurrences" + "/" + type + "/" + name + "/" + startDate + "/" + timezone + "/" + schedule + "/" + runEvery + "/" + days + "/" + days2 + "/" + datesPicked + "/" + weekdayMon + "/" + weekdayTue + "/" + weekdayWed + "/" + weekdayThu + "/" + weekdayFri + "/" + weekdaySat + "/" + weekdaySun + "/" + endDate + "/" + weekdayExcludeMon + "/" + weekdayExcludeTue + "/" + weekdayExcludeWed + "/" + weekdayExcludeThu + "/" + weekdayExcludeFri + "/" + weekdayExcludeSat + "/" + weekdayExcludeSun + "/" + datesPickedExclude + "/" + exclusionMet1 + "/" + exclusionMet2 + "/" + occurrenceCount;
  $.ajax({
    type: "GET",
    dataType: "json",
    url: url,
    success: function(data) {
      $("#scheduleform #next_occurrences").html("<ul>")
      data.forEach(function(d) {
        $("#scheduleform #next_occurrences").append("" + d + "");
      })
      $("#scheduleform #next_occurrences").append("</ul>");
    }
  })
}

function updateScheduleNameInput(inputObject) {
  var $scheduleform = $();
  var $input = $();
  var inputValue = "";

  $input = $('#' + inputObject.id);
  $scheduleform = $input.closest('#scheduleform');
  inputValue = $input.val();

  // don't allow dots in input field
  $input.val(inputValue.replace(/\./g, ""));

  if (inputValue.length > 0) {
    $scheduleform.find("input[type=submit]").removeAttr("disabled");
  } else {
    $scheduleform.find("input[type=submit]").attr("disabled", "disabled");
  } 
}

// don't allow values less than one in the 'run_every' field
function changeRunsEvery() {
  var val = 0;
  val = $("#scheduleform #schedule_run_every").val();
  console.log(val);
  if (val < 1){
    $("#scheduleform #schedule_run_every").val('1');
  }
  getScheduleNextOccurrences();
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

function showWeekday(){
  $('#scheduleform .schedule-simple-period').hide();
  $('#scheduleform #weekday').show();
}

function hideWeekday(){
  $('#scheduleform .schedule-simple-period').show();
  $('#scheduleform #weekday').hide();
}

function advancedScheduleOptions(force=0){
  var $advancedOptions = $("#scheduleform #schedule_advanced");
  var $advancedOptionsToggle = $("#scheduleform #schedule_advanced_toggle");

  if ($advancedOptions.is(":visible") || force === -1){
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
  $('#scheduleform').find("input[type=submit]").attr("disabled", "disabled");
  $('#scheduleform #schedule_schedule').val('monthly');
  changeSchedulePeriod('monthly');
  changeScheduleType('simple');
  changeScheduleDays('specific');
  changeScheduleExclusionMet('cancel');

  // update date & time
  $('#scheduleform #schedule_start_date').val(get_date());
  $('#scheduleform #schedule_start_time').val(get_time());
  $('#scheduleform #timezone_input').set_timezone();

  $('#scheduleform #schedule_dates_picked').val('');
  $('#scheduleform #schedule_dates_picked_exclude').val('');

  $('#scheduleform #schedule_name').val('');
  $('#scheduleform #schedule_exclusion_met1').val('cancel');
  $('#scheduleform #schedule_exclusion_met2').val('mon');
  $('#scheduleform #schedule_run_every').val(1);

  $('#scheduleform #schedule_days').val('specific');
  $('#scheduleform #schedule_days2').val('day');

  $('#scheduleform #daypicker table td').each(function(i){
    $(this).removeClass('active');
  });

  $('#scheduleform #daypicker-exclude table td').each(function(i){
    $(this).removeClass('active');
  });

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

  // reset the button-group-weekdays elements
  $('#scheduleform #button-group-weekdays').each(function(index){
    $(this).find('input').each(function(i){
      $(this).prop("checked", false)
    });
    $(this).find('label').each(function(i){
      $(this).removeClass('active');
    });
  });

  advancedScheduleOptions(-1);

  getScheduleNextOccurrences();
}
