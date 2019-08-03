require 'test_helper'

class UpcomingTransactionsTest < ActiveSupport::TestCase


	test "Get transactions until next payday" do
		user = users(:upcoming_transactions)
		date = "2019-03-01".to_date

		main_schedule = user.schedules.where(type_of: "main").take
		transactions = Schedule.get_all_transactions_until_date(user, main_schedule.next_occurrence_utc, date)

		assert_not transactions.nil?, format_error("Upcoming transactions not set")
		assert transactions.length == 27, format_error("Unexpected amount of transactions", 27, transactions.length)

		schedule_ids = []
		26.times do
			schedule_ids.push(1504)
		end
		schedule_ids.push(1506)

		c_date = date
		transactions.each_with_index do |t, idx|
			assert t.schedule.id == schedule_ids[idx], format_error("Unexpected schedule id", schedule_ids[idx], t.schedule.id)
			
			if t.schedule.id == 1504
				c_date += 1.day
			else
				c_date = "2019-03-15".to_date
			end

			assert t.local_datetime.to_date == c_date, format_error("Unexpected local_datetime", c_date, t.local_datetime.to_date)
		end
	end


	test "Get transactions until next payday DST" do
		user = users(:upcoming_transactions_dst)
		date = "2019-03-28".to_date

		tz = TZInfo::Timezone.get("Europe/London")
		transactions = Schedule.get_all_transactions_until_date(user, tz.local_to_utc("2019-04-26".to_datetime), date)

		schedule_ids = []
		schedule_ids.push(1602)
		28.times do
			schedule_ids.push(1604)
		end
		schedule_ids.push(1606)

		c_date = date

		daily_range = false
		transactions.each_with_index do |t, idx|
			assert t.schedule.id == schedule_ids[idx], format_error("Unexpected schedule id", schedule_ids[idx], t.schedule.id)

			if t.schedule.id == 1604
				unless daily_range
					c_date = date
					daily_range = true
				end
				c_date += 1.day
			elsif t.schedule.id == 1602
				c_date = "2019-04-01".to_datetime
			else
				c_date = "2019-04-15".to_datetime
			end

			assert t.local_datetime.to_date == c_date.to_date, format_error("Unexpected local_datetime", c_date.to_date, t.local_datetime.to_date)
		end

	end

end