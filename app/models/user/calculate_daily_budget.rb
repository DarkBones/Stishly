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
			#cache = ActiveSupport::Cache::MemoryStore.new
			cache = Rails.cache

			cache_name = user.hash_id + '_daily_budget'
			if cache.exist?(cache_name)
				return cache.fetch(cache_name)
			end

			main_schedule = user.schedules.where(type_of: 'main').take

			unless main_schedule.nil?
				result = daily_budget(user, main_schedule)
			else
				result = budget_days(user)
			end

			cache.write(cache_name, result)
			return result
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
				history = a.account_histories.where("date(local_datetime) <= ?", @user_time.to_date - 1.day).order(:local_datetime).reverse_order.take

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
		def get_scheduled_transactions(user, date, currency, reverse: false)
			total = 0
			transactions = []

			Schedule.get_all_transactions_until_date(user, date).each do |t|
				if t.account.account_type == 'spend'
					unless t.is_cancelled
						amount = get_user_amount(t.amount, currency, t.currency)
						total += amount
						t.user_currency_amount = amount
						transactions.push(t)
					end
				end
			end

			transactions = transactions.reverse if reverse

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
			sum = transactions.sum(:user_currency_amount)
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
			scheduled_transactions = get_scheduled_transactions(user, schedule.next_occurrence, user_currency)
			today_transactions = user.transactions.where("date(local_datetime) >= ? AND date(local_datetime) <= ? AND is_cancelled = false AND is_queued = false AND schedule_id IS NULL AND user_currency_amount IS NOT NULL", @user_time.to_date, @user_time.to_date)

			# days until payday
			days_until = (schedule.next_occurrence - @user_time.to_date).to_i

			# calculate the budgets for today and tomorrow
			budget_today = ((balance_start[:total] + scheduled_transactions[:total]).to_f / days_until).round
			if budget_today < 0
				budget_today = 0
			end
			if days_until > 1
				budget_tomorrow = ((balance_now + scheduled_transactions[:total]).to_f / (days_until - 1)).round
			else
				budget_tomorrow = budget_today
			end

			# average daily spending
			average_spend = get_average_spending(user)

			spend_percentage = ((100.to_f/budget_tomorrow) * (average_spend[:amount] * -1)).round(1)

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
			status_message = I18n.t("pages.daily_budget.status_messages.#{status}.main")
			status_message = status_message.sub("@tomorrow@", Money.new(budget_tomorrow, user_currency.iso_code).format)
			status_message = status_message.sub("@percent@", spend_percentage.to_s)
			status_message = status_message.sub("@average@", Money.new((average_spend[:amount] * -1), user_currency.iso_code).format)

			spent_today = today_transactions.sum(:user_currency_amount) * -1
			spent_perc = ((100.to_f/budget_today) * spent_today).round(1)

			if spent_perc <= 75
				spent_color = 'success'
			elsif spent_perc < 100
				spent_color = 'warning'
			else
				spent_color = 'danger'
			end

			result = {
				type: 'daily_budget',
				balance: {
					start: balance_start[:total],
					now: balance_now,
					spent: spent_today,
					spent_color: spent_color
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
			user_currency = Money::Currency.new(user.currency) # the user's currency
			accounts = user.accounts.where(account_type: 'spend') # the user's spending accounts

			balance_now = get_balance_now(accounts, user_currency) # the spending balance as is


			# average daily spending
			average_spend = get_average_spending(user)
			# get all scheduled transactions for a year
			scheduled_transactions = get_scheduled_transactions(user, @user_time.to_date + 90.days, user_currency, reverse: true)

			# return if the balance is less than or equal to 0
			if balance_now <= 0
				return {
					type: 'days',
					days: 0,
					balance: balance_now,
					transactions_total: scheduled_transactions[:total] * 4,
					average_spending: average_spend
				}
			end

			# how much the user spends in a whole year
			annual_spend = ((average_spend[:amount] * 365) + (scheduled_transactions[:total] * 4)) * -1
			if annual_spend <= 0 || average_spend[:amount] >= 0 # if the user is spending a negative amount, return -1 for infinity
				return {
					type: 'days',
					days: '∞',
					balance: balance_now,
					transactions_total: scheduled_transactions[:total] * 4,
					average_spending: average_spend
				}
			elsif balance_now - annual_spend >= 0 # if the balance is higher than what a user spends in a year, take a shortcut calculating the days
				day_spend = annual_spend / 365
				return {
					type: 'days',
					days: balance_now / day_spend,
					balance: balance_now,
					transactions_total: scheduled_transactions[:total] * 4,
					average_spending: average_spend
				}
			end

			balance = balance_now
			current_date = @user_time.to_date
			next_scheduled_transaction = scheduled_transactions[:transactions].pop
			days = 0
			scheduled_transactions_total = 0
			while balance > 0
				balance += average_spend[:amount]

				unless next_scheduled_transaction.nil?
					while next_scheduled_transaction.local_datetime.to_date <= current_date
						amount = get_user_amount(next_scheduled_transaction.amount, user_currency, next_scheduled_transaction.currency)

						balance += amount
						scheduled_transactions_total += amount

						next_scheduled_transaction = scheduled_transactions[:transactions].pop
						break if next_scheduled_transaction.nil?
					end
				end

				current_date += 1.day

				days += 1 if balance >= 0
			end

			days = '∞' if days < 0

			return {
					type: 'days',
					days: days,
					balance: balance_now,
					transactions_total: scheduled_transactions_total,
					average_spending: average_spend
				}

		end

	end
end