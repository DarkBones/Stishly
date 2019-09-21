class Schedule
	class GetTransactionsUntilDate

		def initialize(user, end_date, start_date=nil)
			@end_date = end_date
			@start_date = start_date
			@start_date ||= Time.now.utc

			@user = user

			@schedules = @user.schedules.where("next_occurrence_utc > ? AND next_occurrence_utc < ? AND is_active = true", @start_date, @end_date)
    	@tz = TZInfo::Timezone.get(@user.timezone)
		end

		def perform
			transactions = []
			
			@schedules.each do |schedule|

				next_occurrence = get_next_occurrence(schedule)
				period_id = schedule.current_period_id

				while next_occurrence < @end_date do

					next_occurrence_local = Schedule.next_occurrence(schedule, date: next_occurrence.to_date, testing: true, return_datetime: true)
					next_occurrence_local = @tz.utc_to_local(next_occurrence_local)
					period_id += 1
					break if next_occurrence_local >= @end_date

					transactions += get_transactions(schedule, period_id, next_occurrence_local)

					next_occurrence += 1.day
				end

			end

			return transactions.sort_by { |hsh| hsh[:local_datetime] }

		end

private

		def get_next_occurrence(schedule)
			next_occurrence = schedule.pause_until_utc
			next_occurrence ||= schedule.next_occurrence_utc
		end

		def get_transactions(schedule, period, date)
			transactions = []

			schedule.user_transactions.where(parent_id: nil).each do |transaction|
				t = transaction.dup

				# check if transaction was edited
				edited_transactions = schedule.user.transactions.where(
					schedule_id: schedule.id,
					schedule_period_id: period,
					scheduled_transaction_id: transaction.id,
					parent_id: nil).take
				edited_transaction = nil
				unless edited_transactions.nil?
					edited_transaction = Transaction.find_main_transaction(edited_transactions)
				end

				if edited_transaction
					next unless edited_transaction.is_scheduled
					t = edited_transaction
					t.description = edited_transaction.description
					t.id = edited_transaction.id
				else
					t.id = transaction.id
					t.schedule_period_id = period
				end

				t.schedule = schedule
				t.local_datetime = date.to_date
				t.schedule_period_id = period
				transactions.push(t)
			end

			return transactions
		end

	end
end