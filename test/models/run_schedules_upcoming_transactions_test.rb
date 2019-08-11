require 'test_helper'

class RunSchedulesUpcomingTransactionsTest < ActiveSupport::TestCase

	test "run schedules" do
		"""
		there are 10 transactions in the schedule; 'original x' to 'original n'
		transaction three was cancelled, so should not run
		transaction six was edited, so the edited name should appear
		transaction eight already ran manually, so should not run
		"""
    datetime = Time.local(2019, 4, 30, 1, 0, 0).to_date
    schedules = []
    schedules.push(schedules(:upcoming_transactions_daily_run))

    transactions = Schedule.run_schedules(datetime, schedules)
    
    descriptions = []
    transactions.each do |t|
    	descriptions.push(t.description)
    end

    assert descriptions.length == 8, format_error("Unexpected number of transactions", 8, descriptions.length)
    assert descriptions.include?("original one")
    assert descriptions.include?("original two")
    assert descriptions.include?("original four")
    assert descriptions.include?("original five")
    assert descriptions.include?("original six edited")
    assert descriptions.include?("original seven")
    assert descriptions.include?("original nine")
    assert descriptions.include?("original ten")
  end


end
