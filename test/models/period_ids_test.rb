require 'test_helper'

class PeriodIdsTest < ActiveSupport::TestCase
  test "Period ids" do
    current_user = users(:schedule_period_ids)
    
    transactions = Schedule.run_schedules(nil, current_user.schedules)

    transactions.each do |t|
    	assert t.description == "This was not run yet", format_error("Unexpected transaction description", "This was not run yet", t.description)
    end

    assert transactions.length == 2, format_error("Unexpected amount of transactions", 2, transactions.length)
  end

end