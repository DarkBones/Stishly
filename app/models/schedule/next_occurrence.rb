class Schedule
  class NextOccurrence

    def initialize(schedule, date=nil)
      @schedule = schedule
      @date = date
      @Initialized_date = date

      puts "Initialized with date #{@date}"
    end

    def perform(excluded=false)
      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      # if no date given, set date to today
      @date ||= tz.utc_to_local(Time.now).to_date
      puts "\tDate after timezone set: #{@date}"

      # check if the schedule expired
      return nil if schedule_expired

      # return the date if it runs on this date and is not excluded
      puts "\tInitialized date #{@date} runs on first try" if runs_on_date && !is_excluded
      return @date if runs_on_date && !is_excluded

      puts "\tDate #{@date} was excluded" if runs_on_date && is_excluded
      return run_exclusion_rule(true) if runs_on_date && is_excluded

      # find the next date
      return find_next_date(excluded)

    end

    # finds the next scheduled date
    def find_next_date(excluded=false)
      puts "Searching for next run date after #{@date}"

      case @schedule.period
      when 'days'
        return @date + ((@schedule.start_date - @date) % @schedule.period_num)
      when 'weeks'
        if @schedule.days == 0
          return @date + ((@schedule.start_date.wday - @date.wday) % 7) + (7 * ((@schedule.start_date - @date) % @schedule.period_num))
        else 
          puts @date
          new_date = @date + find_next_in_bitmask(@schedule.days, @date.wday, 7) + 1
          puts new_date

          if @date.wday > bitmask(@schedule.days).length
            weeks_since_startdate = (@date - @schedule.start_date) / 7
            new_date += (@schedule.period_num - (weeks_since_startdate % @schedule.period_num)).to_i * 7
          end

          return new_date
        end
      when 'months'
        if @schedule.days_month == 'specific' || (@schedule.days == 0 && (@schedule.days_month == 'specific' || @schedule.days_month == ''))
          # if the date was a result of an exclusion rule, set the date to the next valid date
          if was_excluded(@date.day-1) && @date != @schedule.start_date
            puts "\tDate #{@date - 1} was the result of an exclusion"
            if @schedule.exclusion_met == 'previous' || @schedule.exclusion_met == 'cancel'

              puts "\tThe un-excluded date for #{@date} is #{(@date-1).day + find_next_in_bitmask(@schedule.days, @date.day, Date.new(@date.year, @date.month, -1).day)}"
              @date += find_next_in_bitmask(@schedule.days, (@date-1).day, Date.new(@date.year, @date.month, -1).day)

              @date += 1 if @schedule.exclusion_met != 'cancel' && !excluded

            elsif @schedule.exclusion_met == 'next' && @date != @Initialized_date
              puts "\tThe un-excluded date for #{@date-1} is #{@date - find_previous_in_bitmask(@schedule.days, (@date).day, Date.new(@date.year, @date.month, -1).day)}"
              @date -= find_previous_in_bitmask(@schedule.days, (@date).day, Date.new(@date.year, @date.month, -1).day)
            end
          end

          if @schedule.days == 0

            days = 0b0 | (1 << @schedule.start_date.day)
            new_date = @date + (@schedule.period_num-1).months
            new_date += find_next_in_bitmask(days, new_date.day, Date.new(new_date.year, new_date.month, -1).day)

            return new_date
          else
            if @date.day > bitmask(@schedule.days).length - 2
              puts "\tAdvancing the month after #{@date}"
              months_since_startdate = (@date.year * 12 + @date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
              @date += ((@schedule.period_num - (months_since_startdate % @schedule.period_num)).to_i).months
              @date = @date.at_beginning_of_month
              puts "\tnew month = #{@date}"
              #@date += (@schedule.period_num-1).months
            end

            @date += find_next_in_bitmask(@schedule.days, @date.day, Date.new(@date.year, @date.month, -1).day)

            #@date = run_exclusion_rule if is_excluded

            while is_excluded do
              @date = run_exclusion_rule
            end

            return @date
          end
        else
          # if the date was a result of an exclusion rule, set the date to the next valid date
          if was_excluded((@date-1).wday) && @date != @schedule.start_date
            #@date += find_next_in_bitmask(@schedule.days, @date.wday)
            if @schedule.exclusion_met == 'previous' || @schedule.exclusion_met == 'cancel'

              puts "\tThe un-excluded date for #{@date} is #{@date + (@date-1).day + find_next_in_bitmask(@schedule.days, @date.day, Date.new(@date.year, @date.month, -1).day)}"
              @date += find_next_in_bitmask(@schedule.days, (@date-1).day, Date.new(@date.year, @date.month, -1).day)

              @date += 1 if @schedule.exclusion_met != 'cancel' && !excluded

            elsif @schedule.exclusion_met == 'next' && @date != @Initialized_date
              puts "\tThe un-excluded date for #{@date-1} is #{@date - find_previous_in_bitmask(@schedule.days, (@date).day, Date.new(@date.year, @date.month, -1).day)}"
              @date -= find_previous_in_bitmask(@schedule.days, (@date).day, Date.new(@date.year, @date.month, -1).day)
            end
          end

          non_specific = find_next_non_specific
          #puts "#{@date-1} was excluded" if was_excluded((@date-1).wday) && @date != @schedule.start_date
          puts "#{@date} > #{non_specific}"
          puts was_excluded((@date-1).day, @date-1)
          if @date > non_specific || (@schedule.days_month_day == 'day' && was_excluded((@date-1).day, @date-1) && @date != @schedule.start_date)
            puts "\tAdvancing the month after #{@date}"
            months_since_startdate = (@date.year * 12 + @date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
            @date += ((@schedule.period_num - (months_since_startdate % @schedule.period_num)).to_i).months
            @date = @date.at_beginning_of_month
            puts "\tnew month = #{@date}"
            non_specific = find_next_non_specific
          end

          @date = non_specific
          puts "\tnon specific: #{non_specific}"
        end

        while is_excluded do
          puts @date
          @date = run_exclusion_rule
        end

        return @date

      when 'years'
        year = @date.year + ((@schedule.start_date.year - @date.year) % @schedule.period_num)
        return Date.new(year, @schedule.start_date.month, @schedule.start_date.year)
      else
        return nil
      end
    end

    # checks if a date is the result of an exclusion
    def was_excluded(day, date=nil)
      date ||= @date
      puts @schedule.days
      puts day
      if @schedule.days != 0
        return bitmask(@schedule.days)[day] != '1'
      else
        if @schedule.days_month != 'specific' && @schedule.days_month != ''
          if @schedule.days_month == 'last' && @schedule.days_month_day == 'day'
            puts "end of month = #{date.at_end_of_month.day}"
            #puts "last day exluded = #{day != date.at_end_of_month.day}"
            if @schedule.exclusion_met == 'previous'
              puts "#{date} >> #{date.at_end_of_month}"
              return date != date.at_end_of_month
            elsif @schedule.exclusion_met == 'next'
              return date != date.at_end_of_month
            end
            
          end
        end
      end

      return false
    end

    def run_exclusion_rule(next_only=false)
      puts "\t\tRunning exclusion rule for #{@date}: #{@schedule.exclusion_met}"
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

      case @schedule.exclusion_met
      when 'next'
        puts "\t\tAdding #{(weekdays.index(@schedule.exclusion_met_day) - @date.wday) % 7} to #{@date}"
        return @date + (weekdays.index(@schedule.exclusion_met_day) - @date.wday) % 7
      when 'previous'
        return @date - (@date.wday - weekdays.index(@schedule.exclusion_met_day)) % 7 if !next_only
        @date += 1
        return self.perform(true)
      when 'cancel'
        month_before = @date.month

        @date += find_next_in_bitmask(@schedule.days, @date.day) + 1
        month_after = @date.month

        if month_before != month_after
          months_since_startdate = (@date.year * 12 + @date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          
          puts "olddate = #{@date}"
          puts "add #{((@schedule.period_num - (months_since_startdate % @schedule.period_num)).to_i)} months"
          @date += ((@schedule.period_num - (months_since_startdate % @schedule.period_num)).to_i - 1).months
          puts "newdate = #{@date}"
        end

        return self.perform
      else
        return nil
      end
    end

    # finds the next date if days_month is not 'specific'
    def find_next_non_specific
      #puts "\t\tFinding next non-specific"
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      values = ['first', 'second', 'third', 'fourth']

      weekday = weekdays.index(@schedule.days_month_day)

      case @schedule.days_month
      when 'last'
        return Date.new(@date.year, @date.month, -1) if @schedule.days_month_day == 'day'

        d = Date.new(@date.year, @date.month, -1)
        d -= (d.wday - weekday) % 7
        #puts d
        return d
      else
        return Date.new(@date.year, @date.month, values.index(@schedule.days_month)+1) if @schedule.days_month_day == 'day'

        d = Date.new(@date.year, @date.month, 1)
        puts (weekday - d.wday) % 7
        d += (weekday - d.wday) % 7

        d += (7 * values.index(@schedule.days_month))
        return d
      end
    end

    # finds the next occurrence in a bitmask
    def find_next_in_bitmask(bits, day, mask_length=nil)
      return 0 if bits == 0

      mask = bitmask(bits)
      
      if mask_length != nil
        while mask.length < mask_length do
          mask.push('0')
        end
      end

      mask.each_with_index do |b, idx|
        return idx if mask[(idx + day) % mask.length] == '1'
      end
    end
    
    def find_previous_in_bitmask(bits, day, mask_length=nil)
      return 0 if bits == 0

      day += 1
      
      mask = bitmask(bits)

      if mask_length != nil
        while mask.length < mask_length do
          mask.push('0')
        end
      end

      day = mask.length - day

      mask = mask.reverse

      masktest = ''
      mask.each_with_index do |b, idx|
        if day % mask.length == idx
          masktest += "'#{mask[idx]}'"
        else
          masktest += mask[idx]
        end
      end
      #puts "\t\t\t#{masktest}: #{mask.length}"

      mask.each_with_index do |b, idx|
        if mask[(idx + day) % mask.length] == '1'
          return idx
        end
      end
    end

    # returns true if the @date is greater than the schedule's end date, meaning that the schedule has expired
    def schedule_expired
      return @schedule.end_date && @date > @schedule.end_date
    end

    # returns true if the date matches the exclusion logic
    def is_excluded
      return false if @schedule.period != 'months'

      days_bitmask_exclude = bitmask(@schedule.days_exclude)
      #day_idx = @schedule.days_month == 'specific' ? (@date.wday - 1) % 7 : @date.day

      puts "Checking exclusion for #{@date}"
      if @schedule.days_month == 'specific' || (@schedule.days_month != 'specific' && @schedule.days_month_day == 'day')
        day_idx = (@date.wday - 1) % 7
      else
        day_idx = @date.day
      end

      return days_bitmask_exclude[day_idx] == '1'
    end

    # returns the bitmask as array from an integer
    def bitmask(int)
      return int.to_s(2).reverse.split('')
    end

    # returns true if the schedule runs on the date (not counting exclusion rules)
    def runs_on_date

      # if the schedule hasn't started yet
      return false if @date < @schedule.start_date

      case @schedule.period
      when 'days'

        return (@date - @schedule.start_date) % @schedule.period_num == 0

      when 'weeks'

        weeks_since_startdate = (@date - @schedule.start_date) / 7
        
        # if not scheduled for this week
        return false if weeks_since_startdate.floor % @schedule.period_num != 0

        # if there is an integer weeks since the start date, and there are no advanced rules
        return weeks_since_startdate.to_i == weeks_since_startdate if @schedule.days == 0

        # if there are advanced rules, check the bitmask against the current date
        puts @date
        puts "#{bitmask(@schedule.days).to_s}: #{(@date.wday - 0) % 7}"
        return bitmask(@schedule.days)[(@date.wday - 1) % 7] == '1'

      when 'months'

        # if not scheduled for this month
        return false if (@date.month - @schedule.start_date.month) % @schedule.period_num != 0

        # if no advanced rules, and date matches
        return @date.day == @schedule.start_date.day if @schedule.days == 0 && (@schedule.days_month == 'specific' || @schedule.days_month == '')

        # if scheduled to run on a specific date, and today matches the bitmask
        return bitmask(@schedule.days)[@date.day] == '1' if @schedule.days_month == 'specific' || (@schedule.days == 0 && (@schedule.days_month == 'specific' || @schedule.days_month == ''))

        d = find_next_non_specific
        return @date == d

      when 'years'

        return (@date.year - @schedule.start_date.year) % @schedule.period_num == 0

      else

        return false

      end

    end

  end
end
