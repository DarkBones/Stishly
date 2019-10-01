class User
	class CalculateDailyBudget

		def initialize(user)
			@user = user
		end

		def perform
			return calculate_daily_budget(@user)
		end

private

		def calculate_daily_budget(user)
			main_schedule = user.schedules.where(type_of: 'main').take

			unless main_schedule.nil?
				return daily_budget(user, main_schedule)
			else
				return budget_days(user)
			end
		end

		# calculates money that can be spent each day
		def daily_budget(user, schedule)
			transactions = Schedule.get_all_transactions_until_date(user, schedule.next_occurrence)
			currency = Money::Currency.new(user.currency)
			balance = user.accounts.where(account_type: 'spend').sum(:balance)

			return 0 if balance.nil? || balance <= 0

			expenses = 0
			transactions.each do |t|
				if t.account.account_type == 'spend'
					expenses += t.user_currency_amount unless t.is_cancelled
				end
			end

			balance = balance.to_f / currency.subunit_to_unit
			expenses = expenses.to_f / currency.subunit_to_unit

			days_until = (schedule.next_occurrence - Time.now.to_date).to_i

			return 0 if expenses >= balance

			balance -= expenses

			puts balance / days_until

			return balance / days_until
		end

		# calculates days until money runs out
		def budget_days(user)
		end

	end
end