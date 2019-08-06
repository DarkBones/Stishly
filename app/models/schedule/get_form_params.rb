class Schedule
	class GetFormParams

		def initialize(schedule)
			@schedule = schedule
		end

		def perform
			params = {
				type: determine_type(@schedule),
				run_every: run_every(@schedule),
				start_date: start_date(@schedue),
				schedule: schedule(@schedule)
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
			return "monthly" if schedule.period.nil?
			return schedule.period
		end

	end
end