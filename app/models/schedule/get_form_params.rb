class Schedule
	class GetFormParams

		def initialize(schedule)
			@schedule = schedule
		end

		def perform
			schedule_period = schedule(@schedule)
			type = determine_type(@schedule)
			days = days(@schedule)
			params = {
				type: type,
				run_every: run_every(@schedule),
				start_date: start_date(@schedue),
				schedule: schedule_period,
				run_every: run_every(@schedule),
				period_txt: period_txt(schedule_period),
				days: days,
				days2: days2(@schedule),
				advanced: advanced(@schedule, type),
				days_bitmask: days_bitmask(@schedule),
				days_exclude_bitmask: days_exclude_bitmask(@schedule),
				exclusion_met1: @schedule.exclusion_met,
				exclusion_met2: exclusion_met2(@schedule),
				show_datepicker: show_datepicker(days, schedule_period)
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
			return "simple"
		end

		def advanced(schedule, type)
			return true
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

		def days_bitmask(schedule)
			return schedule.days.to_s(2).reverse.split('')
		end

		def days_exclude_bitmask(schedule)
			days = schedule.days_exclude
			days ||= 0
			return days.to_s(2).reverse.split('')
		end

		def exclusion_met2(schedule)
			options = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
			bits = schedule.days.to_s(2).reverse.split('')
			bits.each_with_index do |b, idx|
				return options[idx % options.length] if b == '1'
			end
		end

		def show_datepicker(type, schedule_period)
			return false unless schedule_period == "months"
			return false unless type == "specific"
			return true
		end

	end
end