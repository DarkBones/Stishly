class DailyBudget
	class CalculateDailyBudget

		def initialize(user, budget=nil)
			@user = user
			tz = TZInfo::Timezone.get(user.timezone)
			@user_time = tz.utc_to_local(Time.now.utc)
			@budget = budget
		end

		def perform
			return calculate_daily_budget(@user)
		end

		def perform_light
			return calculate_daily_budget_light(@user, @budget)
		end

private

		def calculate_daily_budget_light(user, budget)

			if budget[:type] == 'daily_budget'
				spent_today = get_spent_today

				spent_perc = ((100.to_f / budget[:budget][:today]) * spent_today).round(1)
				case spent_perc
				when 0...75
					spent_color = 'success'
				when 75...100
					spent_color = 'warning'
				else
					spent_color = 'danger'
				end

				budget[:spent][:color] = spent_color

			end

			return budget

		end

		def get_spent_today(user)
			return user.transactions.where("date(local_datetime) >= ?
				AND date(local_datetime) <= ?
				AND is_cancelled = false
				AND is_queued = false
				AND is_scheduled = false
				AND user_currency_amount IS NOT NULL",
				@user_time.to_date, 
				@user_time.to_date).sum(:user_currency_amount) * -1
		end
		
		def calculate_daily_budget(user)
			main_schedule = user.schedules.where(type_of: 'main').take

			if main_schedule.nil?
				result = budget_days(user)
			else
				result = daily_budget(user, main_schedule)
			end

			return result
		end

		def budget_days(user)
			balance = Account.get_spend_balance(user)

			if balance <= 0
				return {
					type: 'days',
					days: 0,
					balance: balance,
					scheduled_transactions: 0,
					average_spending: average_spending,
				}
			end

			average_spending = get_average_spending(user)

			scheduled_transactions = get_scheduled_transactions(user,
				@user_time.to_date + 90.days, 
				reverse: true)

			# how much a user spends in a whole quarter
			quarter_spend = average_spending[:amount] * 90
			quarter_spend += scheduled_transactions[:total] * -1
			if quarter_spend <= 0 || average_spending[:amount] <= 0
				return {
					type: 'days',
					days: '∞',
					balance: average_spending[:amount] * 90,
					scheduled_transactions: scheduled_transactions[:total],
					average_spending: average_spending,
				}
			elsif balance - quarter_spend >= 0
				return {
					type: 'days',
					days: '90+',
					balance: balance,
					scheduled_transactions: scheduled_transactions[:total] * 4,
					average_spending: average_spending
				}
			end

			stopper = 90
			b = balance
			current_date = @user_time.to_date
			next_scheduled_transaction = scheduled_transactions[:transactions].pop
			days = 0
			scheduled_transactions_total = 0
			while b > 0
				b -= average_spending[:amount]

				unless next_scheduled_transaction.nil?
					while next_scheduled_transaction.local_datetime.to_date <= current_date
						amount = CurrencyRate.convert(
							next_scheduled_transaction.amount,
							next_scheduled_transaction.currency,
							user.currency)

						b += amount
						scheduled_transactions_total += amount

						next_scheduled_transaction = scheduled_transactions[:transactions].pop
						break if next_scheduled_transaction.nil?
					end
				end

				current_date += 1.day

				days += 1 if b >= 0

				stopper -= 1
				if stopper <= 0
					days = '90+'
					break
				end

			end

			return {
					type: 'days',
					days: days,
					balance: balance,
					scheduled_transactions: scheduled_transactions_total,
					average_spending: average_spending
				}

		end

		def daily_budget(user, schedule)
			balance_start = Account.get_spend_balance(user, date: @user_time - 1.day)
			balance_now = Account.get_spend_balance(user)

			scheduled_transactions = get_scheduled_transactions(
				user,
				schedule.next_occurrence)[:total]
			
			# Spent today
			spent_today = get_spent_today(user)

			days_until_payday = (schedule.next_occurrence - @user_time.to_date).to_i

			budget_today = (balance_start + scheduled_transactions).to_f
			budget_today = (budget_today / days_until_payday).round if days_until_payday > 0

			if budget_today < 0
				budget_today = 0
			end

			if days_until_payday > 1
				budget_tomorrow = (balance_now + scheduled_transactions).to_f
				budget_tomorrow = (budget_tomorrow / (days_until_payday - 1)).round
			else
				budget_tomorrow = budget_today
			end

			# get average spending
			average_spending = get_average_spending(user)

			spend_percentage = ((100.to_f/budget_tomorrow) * (average_spending[:amount] * -1)).round(1)

			status_color = 'success'
			if average_spending[:amount] > 0
				status = 'excellent'
				status_icon = 'grin-alt'
			else
				case spend_percentage
				when 0...62.5
					status = 'excellent'
					status_icon = 'grin-alt'
				when 62.5...75
					status = 'good'
					status_icon = 'smile-beam'
				when 75...87.5
					status = 'fair'
					status_icon = 'smile'
				when 87.5...100
					status = 'caution'
					status_icon = 'meh'
					status_color = 'warning'
				else
					status = 'bad'
					status_icon = 'frown'
					status_color = 'danger'
				end
			end

			status_message = I18n.t("pages.daily_budget.status_messages.#{status}.main")
			status_message = status_message.sub("@tomorrow@",
				Money.new(budget_tomorrow, user.currency).format)
			status_message = status_message.sub("@percent@",
				spend_percentage.to_s)
			status_message = status_message.sub("@average@",
				Money.new((average_spending[:amount] * -1),
					user.currency).format)

			spent_perc = ((100.to_f / budget_today) * spent_today).round(1)
			case spent_perc
			when 0...75
				spent_color = 'success'
			when 75...100
				spent_color = 'warning'
			else
				spent_color = 'danger'
			end

			return {
				type: 'daily_budget',
				balance: {
					start: balance_start,
					new: balance_now,
				},
				spent: {
					today: spent_today,
					color: spent_color,
				},
				upcoming_transactions: scheduled_transactions,
				days_until_payday: days_until_payday,
				budget: {
					today: budget_today,
					tomorrow: budget_tomorrow,
				},
				average_spending: {
					status: {
						name: status,
						icon: status_icon,
						color: status_color,
						message: status_message,
					},
					accuracy: average_spending[:accuracy],
					percentage: spend_percentage,
				},
			}
		end

		# returns the average daily spending
		def get_average_spending(user)
			start_date = @user_time.to_date - 30.days
			transactions = user.transactions.where("
				is_scheduled = false
				AND is_cancelled = false
				AND is_scheduled = false
				AND schedule_id IS NULL
				AND is_queued = false
				AND user_currency_amount IS NOT NULL
				AND local_datetime IS NOT NULL
				AND date(local_datetime) >= ?
				", start_date).order(:local_datetime)

			first_transaction = user.transactions.where("
				local_datetime IS NOT NULL
				AND user_currency_amount IS NOT NULL
				").order(:local_datetime).first

			return 0 if first_transaction.nil?

			start_date = first_transaction.local_datetime.to_date if first_transaction.local_datetime.to_date > start_date

			days = (@user_time.to_date - start_date).to_i
			days += 1 if days < 30

			sum = transactions.sum(:user_currency_amount).to_f
			sum = (sum / days).round unless days == 0

			accuracy = ((100.to_f / 30) * days).round(1)

			return {
				amount: sum,
				accuracy: accuracy,
			}

		end

		def get_scheduled_transactions(user, date, reverse: false)
			total = 0
			transactions = []

			Schedule.get_all_transactions_until_date(user, date).each do |t|
				if t.account.account_type == 'spend'
					unless t.is_cancelled
						amount = CurrencyRate.convert(t.amount,
							t.currency,
							user.currency)
						total += amount
						t.user_currency_amount = amount
						transactions.push(t)
					end
				end
			end

			transactions = transactions.reverse if reverse

			return {
				total: total,
				transactions: transactions,
			}
		end

	end
end