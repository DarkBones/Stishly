function scheduleTransactionsForm(scheduleId) {
  $("#sch_transactions_list").html("");
  $.ajax({
    type: "GET",
    dataType: "html",
    url: "/api/schedule_transactions/" + scheduleId,
    beforeSend() {
      insertAjaxSpinner($("#sch_transactions_list"));
    },
    complete() {
      removeAjaxSpinner($("#sch_transactions_list"));
    },
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
    beforeSend() {
      insertAjaxSpinner($("#next_run_date"), 38);
    },
    complete() {
      removeAjaxSpinner($("#next_run_date"));
    },
    success(data) {
      $("#next_run_date").text("Next run date: " + data);
    }
  });
}

function schedulePauseForm(schId) {
  $("#schedule_pause_form #schedule_id").val(schId);
}