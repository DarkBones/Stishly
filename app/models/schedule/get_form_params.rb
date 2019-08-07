class Schedule
	class GetFormParams

		def initialize(schedule)
			@schedule = schedule
		end

		def perform
			schedule_period = schedule(@schedule)
			type = determine_type(@schedule)
			params = {
				type: type,
				run_every: run_every(@schedule),
				start_date: start_date(@schedue),
				schedule: schedule_period,
				run_every: run_every(@schedule),
				period_txt: period_txt(schedule_period),
				days: days(@schedule),
				days2: days2(@schedule),
				advanced: advanced(@schedule, type)
			}
		end

private

		def determine_type(schedule)
			return "advanced" unless schedule.end_date.nil?
			advanced_features = [
				schedule.days.to_i,
				schedule.days_month.to_s.length,
				schedule.days_month_day.to_i,
				schedule.days_exclude.to_i,
				schedule.exclusion_met.to_s.length,
				schedule.exclusion_met_day.to_i
			].sum
			return "advanced" if advanced_features > 0
			return "advanced"
		end

		def advanced(schedule, type)
			return false if type != "advanced"
			advanced_features = [
				schedule.days_exclude.to_i,
				schedule.exclusion_met.to_s.length,
				schedule.exclusion_met_day.to_i
			].sum
			return true if advanced_features > 0
			return false
		end

		def run_every(schedule)
			return 1 if schedule.period_num.nil? || schedule.period_num < 1
			return schedule.period_num
		end

		def start_date(schedule)
			start_date = schedule.start_date unless schedule.nil?
			start_date ||= Time.now
			return start_date.strftime("%d-%b-%Y")
		end

		def schedule(schedule)
			return "weekly" if schedule.period.nil?
			return schedule.period
		end

		def run_every(schedule)
			return 1 if schedule.nil? || schedule.period_num.nil? || schedule.period_num < 1
			return schedule.period_num
		end

		def period_txt(period)
			case period
			when "daily"
				return "days"
			when "weekly"
				return "weeks"
			when "monthly"
				return "months"
			when "anually"
				return "years"
			end
		end

		def days(schedule)
			return "specific" if schedule.nil? || schedule.days_month.nil?
			return schedule.days_month
		end

		def days2(schedule)
			options = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
			bits = schedule.days.to_s(2).reverse.split('')
			bits.each_with_index do |b, idx|
				return options[idx % options.length] if b == '1'
			end
		end

	end
end