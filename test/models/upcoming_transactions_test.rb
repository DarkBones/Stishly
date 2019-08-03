require 'test_helper'

class UpcomingTransactionsTest < ActiveSupport::TestCase

	test "Get transactions until next payday" do
		user = users(:upcoming_transactions)

		main_schedule = user.schedules.where(type_of: "main").take
		transactions = Schedule.get_all_transactions_until_date(user, main_schedule.next_occurrence_utc, "2019-03-01".to_date)

		assert_not transactions.nil?, format_error("Upcoming transactions not set")
		assert transactions.length == 27, format_error("Unexpected amount of transactions", 26, transactions.length)
	end

end