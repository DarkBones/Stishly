function resetTransactionsToScheduleForm() {
  var $scheduleTarget, $selectedTransactionsTarget, $transactionsTarget;

  $scheduleTarget = $("#transactions_to_schedule #sch_transactions_schedule_schedules");
  $selectedTransactionsTarget = $("#transactions_list #selected-transactions");
  $transactionsTarget = $("#transactions_to_schedule #schedules_transaction_transactions");

  $scheduleTarget.prop("selectedIndex", 0);
  $transactionsTarget.val($selectedTransactionsTarget.val());
}