function resetTransactionsToScheduleForm() {
  var $scheduleTarget, $selectedTransactionsTarget, $transactionsTarget;

  $scheduleTarget = $("#transactions_to_schedule #schedule_join_schedules");
  $selectedTransactionsTarget = $("#transactions_list #selected-transactions");
  $transactionsTarget = $("#transactions_to_schedule #schedule_join_transactions")

  $scheduleTarget.prop("selectedIndex", 0);
  $transactionsTarget.val($selectedTransactionsTarget.val());
}