class Schedule
  class NextOccurrence

    def initialize(schedule, date=nil, testing=false, return_datetime=false)
      @schedule = schedule
      @date = date
      @testing = testing
      @return_datetime = return_datetime
    end

    def perform
      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      # if no date given, set date to today
      @date ||= tz.utc_to_local(Time.now).to_date

      @date = tz.utc_to_local(Time.now).to_date if @date < Time.now.to_date && !@testing

      if schedule_expired
        return nil
      end

      next_date = find_next_date

      if @return_datetime
        next_date = next_date.to_datetime
        next_date = tz.local_to_utc(next_date)
      end

      return next_date

    end

    def find_next_date
      case @schedule.period
      when 'days'
        return find_next_day
      when 'weeks'
        return find_next_week
      when 'months'
        return find_next_month
      when 'years'
        return find_next_year
      else
        return nil
      end
    end

    # returns the bitmask as array from an integer
    def bitmask(int)
      return int.to_s(2).reverse.split('')
    end

    # finds the next occurrence in a bitmask
    def find_next_in_bitmask(bits, day, mask_length=nil, reverse=false)
      return 0 if bits == 0

      mask = bitmask(bits)

      if mask_length != nil
        while mask.length < mask_length do
          mask.push('0')
        end
      end

      if reverse
        day = mask.length - day
        mask = mask.reverse
      end

      mask.each_with_index do |b, idx|
        if mask[(idx + day) % mask.length] == '1'
          return idx
        end
      end
    end

    # returns the last day of a given month (31, 30, 28)
    def month_length(date)
      return Date.new(date.year, date.month, -1).day
    end

    # finds the next run date if period is 'days'
    def find_next_day
      day = @date + ((@schedule.start_date - @date) % @schedule.period_num)
      return day
    end

    def find_next_year
      year = @date.year
      year += @schedule.period_num - ((@schedule.start_date.year - @date.year) % @schedule.period_num) if @date != @schedule.start_date
      return Date.new(year, @schedule.start_date.month, @schedule.start_date.day)
    end

    # finds the next run date if period is 'weeks'
    def find_next_week
      if @schedule.days == 0
        date = @date + ((@schedule.start_date.wday - @date.wday) % 7) + (7 * ((@schedule.start_date - @date) % @schedule.period_num))
        return date
      else
        date = @date + find_next_in_bitmask(@schedule.days, @date.wday, 7)

        if @date.wday >= bitmask(@schedule.days).length
          date += periods_to_add * 7
        end

        return date
      end
    end

    # calculates how many periods (weeks / months) to add
    def periods_to_add(date=nil)
      date ||= @date
      case @schedule.period
      when 'weeks'
        weeks_to_add = 0
        if date.wday >= bitmask(@schedule.days).length
          weeks_since_startdate = (date - @schedule.start_date) / 7
          weeks_to_add = (@schedule.period_num - (weeks_since_startdate % @schedule.period_num)).to_i
        end

        return weeks_to_add
      when 'months'
        days = get_days_month(date)

        months_to_add = 0
        if date.day >= bitmask(days).length-1 || date.day <= bitmask(days).index('1')
          months_since_startdate = (date.year * 12 + date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          
          if (months_since_startdate % @schedule.period_num) > 0
            months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
          end
        end

        return months_to_add

      end
    end

    # returns the days to be used in a bitmask
    def get_days_month(date=nil)
      date ||= @date

      return @schedule.days if @schedule.days > 0

      if @schedule.days_month != 'specific'
        if @schedule.days_month == 'last' && @schedule.days_month_day == nil
          return 0b0 | (1 << date.at_end_of_month.day)
        end
      end

      return 0b0 | (1 << @schedule.start_date.day)
    end

    # runs the exclusion rule
    def run_exclusion(date)
      case @schedule.exclusion_met
      when 'next'
        return date + ((@schedule.exclusion_met_day - date.wday) % 7)
      when 'previous'
        return date - ((date.wday - @schedule.exclusion_met_day) % 7)
      when 'cancel'
        return run_cancel_exclusion(date)
      end

      return date
    end

    # runs the 'cancel' exclusion option to find the next date
    def run_cancel_exclusion(date)
      date += 1

      return find_next_non_specific(date) if @schedule.days_month != '' && @schedule.days_month !='specific'

      date += find_next_in_bitmask(get_days_month(date), date.day, month_length(date))
      date += periods_to_add(date).months

      # required for dates with day larger than 28 (not included in all months)
      if @schedule.days > 0
        while bitmask(@schedule.days)[date.day] != '1' do
          date += find_next_in_bitmask(get_days_month, date.day, month_length(date))
          date += periods_to_add(date).months
        end
      end

      return date
    end

    # returns true if the given date is excluded
    def is_excluded(date)
      return false if @schedule.days_exclude == 0

      days_bitmask_exclude = bitmask(@schedule.days_exclude)
      if @schedule.days_month == 'specific' || (@schedule.days_month != 'specific' && @schedule.days_month_day == nil)
        day_idx = (date.wday) % 7
      else
        day_idx = date.day
      end

      return days_bitmask_exclude[day_idx] == '1'
    end

    # returns true if given date was the result of an exclusion rule
    def was_excluded(date)
      if @schedule.days_month == 'specific'
        return false if bitmask(@schedule.days)[date.day] == '1'

        if @schedule.exclusion_met_day
          return date.wday == @schedule.exclusion_met_day
        end
      elsif @schedule.days_month == 'last' 
        if @schedule.days_month_day == nil
          return date.at_end_of_month != date
        else
          return date.wday != @schedule.days_month_day
        end
      elsif @schedule.days_month_day == nil
        values = ['first', 'second', 'third', 'fourth']
        return date.day != (values.index(@schedule.days_month) + 1)
      else
        weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
        return date.wday != weekdays.index(@schedule.days_month_day)
      end

      return false
    end

    # reverse of exclusion
    def unexclude(date)
      date_p = date

      case @schedule.exclusion_met
      when 'previous'
        if @schedule.days_month == 'specific' || (@schedule.days_month != 'specific' && @schedule.days_month == nil)
          date += find_next_in_bitmask(get_days_month(date), date.day, month_length(date))
        else
          date = find_next_non_specific(date)
        end
      when 'next'
        date -= find_next_in_bitmask(get_days_month(date), date.day, month_length(date), true)
      end

      return date
    end

    # find the next non-specific date
    def find_next_non_specific(date)
      values = ['first', 'second', 'third', 'fourth']

      case @schedule.days_month
      when 'last'
        d = Date.new(date.year, date.month, -1)

        return d if @schedule.days_month_day == nil

        d -= ((d.wday - @schedule.days_month_day) % 7)

        if d < date
          d = d.at_beginning_of_month

          months_since_startdate = (d.year * 12 + d.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          
          months_to_add = @schedule.period_num
          if (months_since_startdate % @schedule.period_num) > 0
            months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
          end

          d += months_to_add.months
          return find_next_non_specific(d)
        end

        return d
      else
        if @schedule.days_month_day == nil
          if values.index(@schedule.days_month) + 1 < date.day
            months_to_add = @schedule.period_num
            months_since_startdate = (date.year * 12 + date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
            if (months_since_startdate % @schedule.period_num) > 0
              months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
            end
            date += months_to_add.months
          end
          
          return Date.new(date.year, date.month, values.index(@schedule.days_month)+1) if @schedule.days_month_day == nil
        end
        
        d = Date.new(date.year, date.month, 1)
        d += (@schedule.days_month_day - d.wday) % 7
        d += (7 * values.index(@schedule.days_month))

        if d < date
          d = d.at_beginning_of_month

          months_since_startdate = (d.year * 12 + d.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          
          months_to_add = @schedule.period_num
          if (months_since_startdate % @schedule.period_num) > 0
            months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
          end

          d += months_to_add.months

          d = Date.new(d.year, d.month, 1)
          d += (@schedule.days_month_day - d.wday) % 7
          d += (7 * values.index(@schedule.days_month))
        end

        return d
      end
    end

    def find_next_month
      days = get_days_month
      date = @date

      date = unexclude(date-1) + 1 if was_excluded(date-1) && date != @schedule.start_date

      if @schedule.days_month == '' || @schedule.days_month == 'specific'
        date += find_next_in_bitmask(days, date.day, month_length(date))
        date += periods_to_add(date).months

        # required for dates with day larger than 28 (not included in all months)
        if @schedule.days > 0
          while bitmask(@schedule.days)[date.day] != '1' do
            date += find_next_in_bitmask(days, date.day, month_length(date))
            date += periods_to_add(date).months
          end
        end

      else
        date += periods_to_add(date).months
        date = find_next_non_specific(date)
      end

      excluded_counter = 0
      while is_excluded(date)
        excluded_counter += 1

        if excluded_counter > 100
          return nil
        end
        date = run_exclusion(date)
      end

      return date
    end

    # returns true if the schedule has expired
    def schedule_expired
      return @schedule.end_date && @date > @schedule.end_date
    end

  end
end