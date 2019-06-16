require 'test_helper'

class RunSchedulesTest < ActiveSupport::TestCase
  
  test "run schedules" do
    datetime = Time.local(2019, 4, 30, 1, 0, 0).to_date
    schedules = []
    schedules.push(schedules(:payday))
    schedules.push(schedules(:bonus_day))
    schedules.push(schedules(:payday_cvg))
    schedules.push(schedules(:bonus_day_cvg))
    schedules.push(schedules(:innactive))
    schedules.push(schedules(:bas))
    schedules.push(schedules(:overlap_main))
    schedules.push(schedules(:overlap_every_day))
    schedules.push(schedules(:overlap_every_2_days))

    transactions = Schedule.run_schedules(datetime, schedules)
    
    assert transactions.length == 10, format_error("Unexpected scheduled transactions amount", 10, transactions.length)

    transactions.each do |t|
    	assert t.is_scheduled == false, format_error("Transaction must not be scheduled")
        assert_not t.user_id.nil?, format_error("User ID is nul")
        assert_not t.account_currency_amount.nil?, format_error("Account currency amount is nul")
        assert_not t.user_currency_amount.nil?, format_error("User currency amount is nul")

        assert t.account_currency_amount != 0, format_error("Unexpected account currency amount", "!0", t.account_currency_amount)
        assert t.user_currency_amount != 0, format_error("Unexpected user currency amount", "!0", t.user_currency_amount)
    end

  end

  test "multiple transactions" do
    datetime = Time.local(2019, 4, 30, 1, 0, 0).to_date

    schedules = []
    schedules.push(schedules(:overlap_every_day_2))

    transactions = Schedule.run_schedules(datetime, schedules)

    assert transactions.length == 5, format_error("Unexpected amount of transactions", 5, transactions.length)
  end

  test "multiple transfer transactions" do
    datetime = Time.local(2019, 4, 30, 1, 0, 0).to_date

    schedules = []
    schedules.push(schedules(:overlap_every_day_3))

    transactions = Schedule.run_schedules(datetime, schedules)

    assert transactions.length == 10, format_error("Unexpected amount of transactions", 10, transactions.length)

  end

end