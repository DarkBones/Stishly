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
    
    assert transactions.length == 14, format_error("Unexpected scheduled transactions amount", 14, transactions.length)

    transactions.each do |t|
    	assert t.is_scheduled == false, format_error("Transaction must not be scheduled")
    end

  end

end