class Schedule
  class CreateFromSimpleForm

  	def initialize(current_user, params, type="Schedule", schedule_name=nil, invert_amount=true)
  		@current_user = current_user
  		@params = params
  		@schedule_name = schedule_name
  		@type = type
  		@invert_amount = invert_amount
  	end

  	def perform
  		return if @params.nil?
  		
  		schedule_params = parse_simple_params(@params, @schedule_name)
  		schedule = Schedule.create_from_form(schedule_params, @current_user, false, @type)
  		schedule.save

  		transaction_params = parse_transaction_params(@params, schedule)

  		transaction = @current_user.transactions.new(transaction_params)
  		transaction.save

  		Transaction.join_to_schedule(transaction, schedule)
  	end

private

		def parse_transaction_params(params, schedule)
			return if params.key?("amount")

			amount = get_amount(params)
			direction = 1
			direction = -1 if amount < 0
			account = Account.get_from_name(params[:account], @current_user)
			queue = 0
			queue = 1 unless params[:fixed_amount] == "fixed"

			transaction = {
				user_id: @current_user.id,
				amount: amount,
				direction: direction,
				description: get_description(params),
				account_id: account.id,
				currency: params[:currency],
				category_id: -1,
				is_scheduled: 1,
				schedule_id: schedule.id,
				queue_scheduled: queue
			}

			return transaction
		end

		def get_description(params)
			return params[:category_name] if params[:category] == "other"
			return params[:category]
		end

		def get_amount(params)
			if params[:fixed_amount] == "fixed"
				amount = params[:amount].to_f
			else
				amount = params[:average_amount].to_f
			end

			amount = Currency.float_to_int(amount, params[:currency])
			amount *= -1 if @invert_amount

			return amount
		end

		def parse_simple_params(params, schedule_name)

			schedule_name ||= get_name(params)
			schedule_period = "monthly"

			if params[:period] == "weeks"
				schedule_period = "weekly"
			elsif params[:period] == "days"
				schedule_period = "daily"
			end

			return {
				type: "advanced",
				name: schedule_name,
				start_date: User.current_time.to_date,
				timezone: @current_user.timezone,
				schedule: schedule_period,
				run_every: params[:periodNum].to_i,
				days: get_days(params),
				day2: params[:month_day2],
				days2: params[:month_day2],
				dates_picked: get_dates_picked(params),
				weekday_mon: get_weekday(params, "mon"),
				weekday_tue: get_weekday(params, "tue"),
				weekday_wed: get_weekday(params, "wed"),
				weekday_thu: get_weekday(params, "thu"),
				weekday_fri: get_weekday(params, "fri"),
				weekday_sat: get_weekday(params, "sat"),
				weekday_sun: get_weekday(params, "sun"),
				end_date: "",
				weekday_exclude_mon: get_weekday_exclude(params, "mon"),
				weekday_exclude_tue: get_weekday_exclude(params, "tue"),
				weekday_exclude_wed: get_weekday_exclude(params, "wed"),
				weekday_exclude_thu: get_weekday_exclude(params, "thu"),
				weekday_exclude_fri: get_weekday_exclude(params, "fri"),
				weekday_exclude_sat: get_weekday_exclude(params, "sat"),
				weekday_exclude_sun: get_weekday_exclude(params, "sun"),
				dates_picked_exclude: "",
				exclusion_met1: get_exclusion_met1(params),
				exclusion_met2: get_exclusion_met2(params)
			}

		end

		def get_exclusion_met2(params)
			return "" unless params[:period] == "months"
			return "" if params[:month_exclude_wday] == "none"
			return params[:month_exclude_met_day]
		end

		def get_exclusion_met1(params)
			return "" unless params[:period] == "months"
			return "" if params[:month_exclude_wday] == "none"
			return params[:month_exclude_met]
		end

		def get_weekday_exclude(params, day)
			return "0" unless params[:period] == "months"
			return "0" if params[:month_exclude_wday] == "none"

			if params[:month_exclude_wday] == "weekends"
				if day == "sat" || day == "sun"
					return "1"
				else
					if params[:month_exclude_wday] == day
						return "1"
					else
						return "0"
					end
				end
			end
		end

		def get_weekday(params, day)
			return "0" unless params[:period] == "weeks"
			return "0" unless params[:week_day] == day
			return "1"
		end

		def get_dates_picked(params)
			return "" unless params[:period] == "months"
			return "" if params[:month_day2] != "day"

			return params[:month_day]
		end

		# returns specific / first / last / second / third / fourth
		def get_days(params)

			return "specific" if params[:days2] == "day"
			return "last" if params[:month_day] == "last"

			idx = params[:month_day].to_i - 1
			vals = ["first", "second", "third", "fourth"]

			if idx < vals.length
				return vals[idx]
			else
				return "specific"
			end

		end

		def get_name(params)
			return params[:category_name] if params[:category] == "other"
			return params[:category]
		end

  end
end