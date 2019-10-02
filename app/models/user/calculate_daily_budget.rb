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

		# calculates how much a user spends per day on average
		def get_average_spending(user, window: 30)
			start_date = @user_time.to_date - window.days
			transactions = user.transactions.where("is_scheduled = false AND schedule_id IS NULL AND user_currency_amount < 0 AND is_cancelled = false AND is_queued = false AND local_datetime >= ?", start_date).order(:local_datetime)
			first_transaction = user.transactions.where("local_datetime IS NOT NULL AND user_currency_amount IS NOT NULL AND schedule_id IS NULL AND is_cancelled = false AND is_queued = false").order(:local_datetime).first

			if first_transaction.nil?
				return {
					amount: 0,
					accuracy: 0
				}
			end

			start_date = first_transaction.local_datetime.to_date if first_transaction.local_datetime.to_date > @user_time.to_date - window.days

			days = (@user_time.to_date - start_date).to_i
			days += 1 if days < window
			sum = transactions.sum(:user_currency_amount).abs
			sum /= days unless days == 0

			accuracy = ((100.to_f/window) * days).round(1)

			return {
				amount: sum,
				accuracy: accuracy
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

			# average daily spending
			average_spend = get_average_spending(user)
			spend_percentage = ((100.to_f/budget_tomorrow) * average_spend[:amount]).round(1)

			if spend_percentage <= 62.5
				status = 'excellent'
				status_icon = 'grin-alt'
				status_color = 'success'
			elsif spend_percentage <= 75
				status = 'good'
				status_icon = 'smile-beam'
				status_color = 'success'
			elsif spend_percentage <= 87.5
				status = 'fair'
				status_icon = 'smile'
				status_color = 'success'
			elsif spend_percentage <= 100
				status = 'caution'
				status_icon = 'meh'
				status_color = 'warning'
			else
				status = 'bad'
				status_icon = 'frown'
				status_color = 'danger'
			end

			if spend_percentage < 100
				status_message = I18n.t('pages.daily_budget.under')
			else
				status_message = I18n.t('pages.daily_budget.over')
			end
			status_message = status_message.sub("@tomorrow@", Money.new(budget_tomorrow, user_currency.iso_code).format)
			status_message = status_message.sub("@percent@", spend_percentage.to_s)
			status_message = status_message.sub("@average@", Money.new(average_spend[:amount], user_currency.iso_code).format)

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
				},
				average_spending: {
					status: status,
					status_icon: status_icon,
					status_color: status_color,
					status_message: status_message,
					amount: average_spend[:amount],
					accuracy: average_spend[:accuracy],
					percentage: spend_percentage
				}
			}

			return result
		end

		# calculates days until money runs out
		def budget_days(user)
		end

	end
end