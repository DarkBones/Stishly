function scheduleTransactionsForm(scheduleId) {
  $("#sch_transactions_list").html("");
  $.ajax({
    type: "GET",
    dataType: "html",
    url: "/api/schedule_transactions/" + scheduleId,
    success(data) {
      $("#sch_transactions_list").prepend(data);
    }
  });
}

function changeSchedule(schId) {
  $("#next_run_date").text("");
  $.ajax({
    type: "GET",
    dataType: "text",
    url: "/api/get_next_schedule_date/" + schId,
    success(data) {
      $("#next_run_date").text("Next run date: " + data);
    }
  });
}