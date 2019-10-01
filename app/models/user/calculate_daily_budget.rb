class User
	class CalculateDailyBudget

		def initialize(user)
			@user = user
			tz = TZInfo::Timezone.get(user.timezone)
			@user_time = tz.utc_to_local(Time.now.utc)
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

		def get_user_amount(amount, user_currency, currency)
			currency = Money::Currency.new(currency)

			if user_currency.iso_code != currency.iso_code
				amount = CurrencyRate.convert(amount, currency, user_currency)
			end

			#amount = (amount.to_f / user_currency.subunit_to_unit).round(Math.log10(user_currency.subunit_to_unit).ceil)

			return amount
		end

		# returns the amounts in spending accounts as they were on the start of the day
		def get_balance_start(accounts, currency)
			total = 0

			accounts.each do |a|
				# get the latest AccountHistory entry from yesterday
				history = a.account_histories.where("local_datetime < ?", @user_time.to_date - 1.day).order(:local_datetime).reverse_order.take

				# if no history was found, take the earliest one
				history ||= a.account_histories.order(:local_datetime).take

				balance = get_user_amount(history.balance, currency, a.currency)
				total += balance

				a.balance = balance
			end

			return {
				accounts: accounts,
				total: total
			}
		end

		# returns the total spending amount as is
		def get_balance_now(accounts, currency)
			total = 0

			accounts.each do |a|
				total += get_user_amount(a.balance, currency, a.currency)
				puts a.balance
			end

			return total
		end

		# returns all transactions scheduled until next payday
		def get_scheduled_transactions(user, schedule, currency)
			total = 0
			transactions = []

			Schedule.get_all_transactions_until_date(user, schedule.next_occurrence).each do |t|
				if t.account.account_type == 'spend'
					unless t.is_cancelled
						amount = get_user_amount(t.amount, currency, t.currency)
						total += amount
						t.user_currency_amount = amount
						transactions.push(t)
					end
				end
			end

			return {
				transactions: transactions,
				total: total
			}
		end

		# calculates amount that can be spent today
		def daily_budget(user, schedule)
			user_currency = Money::Currency.new(user.currency) # the user's currency
			accounts = user.accounts.where(account_type: 'spend') # the user's spending accounts

			balance_now = get_balance_now(accounts, user_currency) # the spending balance as is (to calculate tomorrow's budget)
			balance_start = get_balance_start(accounts, user_currency) # the spending balance at the start of today

			# get the transactions
			scheduled_transactions = get_scheduled_transactions(user, schedule, user_currency)
			today_transactions = user.transactions.where("local_datetime >= ? AND local_datetime < ?", @user_time.to_date, @user_time.to_date)

			# days until payday
			days_until = (schedule.next_occurrence - @user_time.to_date).to_i

			# calculate the budgets for today and tomorrow
			budget_today = ((balance_start[:total] + scheduled_transactions[:total]).to_f / days_until).round
			if days_until > 1
				budget_tomorrow = ((balance_now + scheduled_transactions[:total]).to_f / (days_until - 1)).round
			else
				budget_tomorrow = budget_today
			end

			result = {
				type: 'daily_budget',
				balance: {
					start: balance_start[:total],
					now: balance_now,
					spend: today_transactions.sum(:user_currency_amount)
				},
				accounts: balance_start[:accounts],
				transactions: {
					scheduled: scheduled_transactions,
					today: today_transactions
				},
				days_until: days_until,
				budget: {
					today: budget_today,
					tomorrow: budget_tomorrow
				}
			}
		end

		# calculates days until money runs out
		def budget_days(user)
		end

	end
end