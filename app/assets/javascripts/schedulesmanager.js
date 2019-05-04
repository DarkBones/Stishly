function scheduleTransactionsForm(scheduleId) {
  $.ajax({
    type: "GET",
    dataType: "html",
    url: "api/schedule_transactions/" + scheduleId,
    success(data) {
      $("#sch_transactions_list").prepend(data);
    }
  });
}