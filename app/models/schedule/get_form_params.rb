class Schedule
  class GetFormParams

    def initialize(schedule)
      @schedule = schedule
      @hidden_fields = []
    end

    def perform
      return get_form_params(@schedule)
    end

private

    def get_form_params(schedule)
      type = determine_type(schedule) # advanced / simple
      name = schedule.name
      period = period(schedule) # monthly / weekly / etc

      unless schedule.period.nil?
        period_txt = I18n.t('models.schedule.periods_text.' + schedule.period)
      else
        period_txt = I18n.t('models.schedule.periods_text.months')
      end

      start_date = start_date(schedule)
      period_num = period_num(schedule)
      days_month1 = days_month1(schedule)
      days_month2 = days_month2(schedule, days_month1)
      days_picked = days_picked(schedule, period, days_month1) # an array of dates based on period: ['mon', 'fri'] or ['1', '14', '21']
      advanced = advanced(schedule, type) # whether very advanced features were used
      end_date = end_date(schedule)
      exclude_days_picked = days_exclude_picked(schedule, period, days_month1, days_month2)
      exclusion_met1 = exclusion_met1(schedule)
      exclusion_met2 = exclusion_met2(schedule, type, period, exclude_days_picked)
      timezone = timezone(schedule)

      return {
        type: type,
        name: name,
        schedule: period,
        period_txt: period_txt,
        start_date: start_date,
        run_every: period_num,
        days: days_month1,
        days2: days_month2,
        days_picked: days_picked,
        advanced: advanced,
        end_date: end_date,
        exclude: exclude_days_picked,
        exclusion_met1: exclusion_met1,
        exclusion_met2: exclusion_met2,
        hidden_fields: @hidden_fields,
        timezone: timezone
      }
    end

    def timezone(schedule)
      return schedule.timezone
    end

    # whether the advanced fields were used
    def determine_type(schedule)
      return "advanced" unless schedule.end_date.nil?
      advanced_features = [
        schedule.days.to_i,
        schedule.days_month.to_s.length,
        schedule.days_month_day.to_i
      ].sum
      return "advanced" if advanced_features > 0

      @hidden_fields.push("advanced")
      return "simple"
    end

    # the schedule period (months / weeks / days etc)
    def period(schedule)
      if schedule.period.nil?
        @hidden_fields.push("daily")
        @hidden_fields.push("weekly")
        @hidden_fields.push("annually")
        return "monthly"
      end

      @hidden_fields.push("daily") unless schedule.period == "days"
      @hidden_fields.push("weekly") unless schedule.period == "weeks"
      @hidden_fields.push("monthly") unless schedule.period == "months"
      @hidden_fields.push("annually") unless schedule.period == "years"
      
      if schedule.period == "days"
        return "daily"
      elsif schedule.period == "weeks"
        return "weekly"
      elsif schedule.period == "months"
        return "monthly"
      elsif schedule.period == "years"
        return "annually"
      end
    end

    # the start date of the schedule
    def start_date(schedule)
      start_date = schedule.start_date
      start_date ||= Time.now
      return date_to_string(start_date)
    end

    def end_date(schedule)
      end_date = schedule.end_date
      return date_to_string(end_date) unless end_date.nil?
    end

    def period_num(schedule)
      return 1 if schedule.period_num.nil? || schedule.period_num < 1
      return schedule.period_num
    end

    # specific / first / last / second / etc
    def days_month1(schedule)
      if schedule.nil? || schedule.days_month == "specific"
        @hidden_fields.push("days2")
        return "specific"
      end

      return schedule.days_month
    end

    # mon / tue / etc
    def days_month2(schedule, type)
      if type.nil? || type.length == 0 || type == "specific"
        @hidden_fields.push("days2") unless @hidden_fields.include?("days2")
        return
      end

      @hidden_fields.push("days2") if schedule.days_month == "specific"
      @hidden_fields.push("datepicker") if schedule.days_month != "specific" && schedule.days_month_day != "day"
      return weekdays_array[schedule.days_month_day] unless schedule.days_month_day.nil?

      return "day"
    end

    def days_picked(schedule, period, days_month1)
      return if period == "monthly" && days_month1 != "specific"
      return if schedule.days == 0

      if period == "monthly"
        return get_monthly_days_picked(schedule.days)
      elsif period == "weekly"
        return get_weekly_days_picked(schedule.days)
      end

    end

    def days_exclude_picked(schedule, period, days_month1, days_month2)
      return unless period == "monthly"

      if days_month1 == "specific" || (days_month1 != "specific" && days_month2 == "day")
        return get_weekly_days_picked(schedule.days_exclude)
      else
        return get_monthly_days_picked(schedule.days_exclude)
      end
    end

    def exclusion_met1(schedule)
      return "cancel" if schedule.nil? || schedule.exclusion_met.nil? || schedule.exclusion_met.length == 0
      return schedule.exclusion_met
    end

    def exclusion_met2(schedule, type, period, days_exclude)
      unless type == "advanced" && period == "monthly" && days_exclude.length > 0
        @hidden_fields.push("exclusion_met_day")
        return
      end

      if schedule.exclusion_met.nil? || schedule.exclusion_met == "cancel" || schedule.exclusion_met.length == 0
        @hidden_fields.push("exclusion_met_day")
        return
      end

      return weekdays_array[schedule.exclusion_met_day] unless schedule.exclusion_met_day.nil?
    end

    def advanced(schedule, type)
      unless type == "advanced"
        @hidden_fields.push("advanced2")
        return false
      end

      return true unless schedule.end_date.nil?

      advanced_features = [
        schedule.days_exclude.to_i,
        schedule.exclusion_met.to_s.length,
        schedule.exclusion_met_day.to_i
      ].sum
      return true if advanced_features > 0

      @hidden_fields.push("advanced2")
      return false
    end

    def get_monthly_days_picked(days)
      days_picked = []
      bits = bitmask(days)
      bits.each_with_index do |b, idx|
        days_picked.push(idx) if b == '1'
      end
      return days_picked
    end

    def get_weekly_days_picked(days)
      days_picked = []
      bits = bitmask(days)
      weekdays = weekdays_array

      bits.each_with_index do |b, idx|
        days_picked.push(weekdays[idx]) if b == '1'
      end

      return days_picked
    end

    # parses a date object to a dd-mm-yyy string
    def date_to_string(date)
      return date.strftime("%d-%b-%Y")
    end

    def weekdays_array
      return ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
    end

    def bitmask(bits)
      return [] unless bits.class == Integer
      return bits.to_s(2).reverse.split('')
    end

  end
end