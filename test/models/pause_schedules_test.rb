require 'test_helper'

class PauseSchedules < ActiveSupport::TestCase
  test "Paused schedules" do
    current_user = users(:pause_schedule)
    
    transactions = Schedule.run_schedules(nil, current_user.schedules)

    assert transactions.length == 1, format_error("Unexpected amount of transactions", 1, transactions.length)
    assert transactions[0].description == "This no longer paused", format_error("Unexpected transaction", "This no longer paused", transactions[0].description)

    schedule = current_user.schedules.where(name: "Unpaused").take
    assert schedule.pause_until_utc.nil?
    assert schedule.pause_until.nil?
  end

end