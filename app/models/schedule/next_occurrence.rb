class Schedule
  class NextOccurrence

    def initialize(schedule, date=nil)
      @schedule = schedule
      @date = date

      puts "initialized with date #{@date}"
    end

    def perform
      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      # if no date given, set date to today
      @date ||= tz.utc_to_local(Time.now).to_date
      puts "  date after timezone set: #{@date}"

      if schedule_expired
        puts "  schedule expired on #{@schedule.end_date}"
        return nil
      end

      return find_next_date

    end

    def find_next_date
      puts "    Searching for next run date after #{@date}"

      case @schedule.period
      when 'days'
        return find_next_day
      when 'weeks'
        return find_next_week
      when 'months'
        return find_next_month
      when 'years'

      else

      end
    end

    # returns the bitmask as array from an integer
    def bitmask(int)
      return int.to_s(2).reverse.split('')
    end

    # finds the next occurrence in a bitmask
    def find_next_in_bitmask(bits, day, mask_length=nil, reverse=false)
      puts "        Searching for next in bitmask, starting on #{day}" if !reverse
      puts "        Searching for previous in bitmask, starting on #{day}" if reverse
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

      # TESTING #
      masktest = ''
      mask.each_with_index do |b, idx|
        if day % mask.length == idx
          masktest += "'#{mask[idx]}'"
        else
          masktest += mask[idx]
        end
      end
      puts "          #{masktest}: #{mask.length}"
      # TESTING #

      mask.each_with_index do |b, idx|
        if mask[(idx + day) % mask.length] == '1'
          puts "          returning #{idx}"
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
      puts "      Find next day resulting in #{day}"
      return day
    end

    # finds the next run date if period is 'weeks'
    def find_next_week
      puts "      Searching for next weekly date"
      if @schedule.days == 0
        date = @date + ((@schedule.start_date.wday - @date.wday) % 7) + (7 * ((@schedule.start_date - @date) % @schedule.period_num))
        puts "      returning #{date}"
        return date
      else
        date = @date + find_next_in_bitmask(@schedule.days, @date.wday, 7)
        puts "      found date #{date}"

        puts "      @date.wday >= bitmask(@schedule.days).length: #{@date.wday} >= #{bitmask(@schedule.days).length}"
        if @date.wday >= bitmask(@schedule.days).length
          date += periods_to_add * 7
          puts "        added #{periods_to_add} week(s) to make #{date}"
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
          puts "        advancing to the next week"
          weeks_since_startdate = (date - @schedule.start_date) / 7
          weeks_to_add = (@schedule.period_num - (weeks_since_startdate % @schedule.period_num)).to_i
        end

        return weeks_to_add
      when 'months'
        days = get_days_month

        months_to_add = 0
        puts "        #{date.day} >= #{bitmask(days).length-1} || <= #{bitmask(days).index('1')}"
        if date.day >= bitmask(days).length-1 || date.day <= bitmask(days).index('1')
          puts "        advancing the month after #{date}"
          months_since_startdate = (date.year * 12 + date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          puts "        months (#{date}) since start date: #{months_since_startdate}"
          
          if (months_since_startdate % @schedule.period_num) > 0
            months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
          end

          puts "#{months_since_startdate} % #{@schedule.period_num} = #{months_since_startdate % @schedule.period_num}"
          puts "        months to add: #{months_to_add}"
        end

        return months_to_add

      end
    end

    # returns the days to be used in a bitmask
    def get_days_month
      puts "          getting days_month"

      puts "          returning #{@schedule.days} because it's already set"
      return @schedule.days if @schedule.days > 0

      if @schedule.days_month != 'specific'
        if @schedule.days_month == 'last' && @schedule.days_month_day == 'day'
          puts "          returning last day of the month: #{0b0 | (1 << @date.at_end_of_month.day)}"
          return 0b0 | (1 << @date.at_end_of_month.day)
        end
      end

      puts "          returning schedule start date: #{0b0 | (1 << @schedule.start_date.day)}"
      return 0b0 | (1 << @schedule.start_date.day)
    end

    # runs the exclusion rule
    def run_exclusion(date)
      case @schedule.exclusion_met
      when 'next'
        date += ((@schedule.exclusion_met_day - date.wday + 1) % 7)
        puts "after exclusion: #{date}"
      when 'previous'
        date -= ((date.wday - @schedule.exclusion_met_day - 1) % 7)
      when 'cancel'
        date += 1
        date += find_next_in_bitmask(get_days_month, date.day, month_length(date))
        date += periods_to_add(date).months
      end

      return date
    end

    # returns true if the given date is excluded
    def is_excluded(date)
      puts "          checking exclusion for #{date}"
      return false if @schedule.days_exclude == 0

      days_bitmask_exclude = bitmask(@schedule.days_exclude)
      if @schedule.days_month == 'specific' || (@schedule.days_month != 'specific' && @schedule.days_month_day == 'day')
        day_idx = (date.wday) % 7
      else
        day_idx = date.day
      end

      puts "          #{date} is excluded" if days_bitmask_exclude[day_idx] == '1'
      puts "          #{date} is not excluded" if days_bitmask_exclude[day_idx] != '1'

      exclude_mask_test = ""
      days_bitmask_exclude.each_with_index do |b, idx|
        if idx == day_idx
          exclude_mask_test += "'#{days_bitmask_exclude[idx]}'"
        else
          exclude_mask_test += days_bitmask_exclude[idx]
        end
      end
      puts exclude_mask_test

      return days_bitmask_exclude[day_idx] == '1'
    end

    # returns true if given date was the result of an exclusion rule
    def was_excluded(date)
      puts "Checking if #{date} was excluded"
      return false if bitmask(@schedule.days)[date.day] == '1'

      if @schedule.days_month == 'specific' || (@schedule.days_month != 'specific' && @schedule.days_month_day == 'day')
        puts "#{date.wday} == #{@schedule.exclusion_met_day+1}" if @schedule.exclusion_met_day
        return date.wday == @schedule.exclusion_met_day+1 if @schedule.exclusion_met_day
      end

      return false
    end

    # reverse of exclusion
    def unexclude(date)
      puts "Unexcluding date #{date}"

      case @schedule.exclusion_met
      when 'previous'
        date += find_next_in_bitmask(get_days_month, date.day, month_length(date))
      when 'next'
        date -= find_next_in_bitmask(get_days_month, date.day, month_length(date), true)
      end

      puts "Unexcluded date: #{date}"
      return date
    end

    def find_next_month
      puts "      Searching for next monthly date"

      days = get_days_month
      date = @date

      date = unexclude(date-1) + 1 if was_excluded(date-1)

      date += find_next_in_bitmask(days, date.day, month_length(date))
      date += periods_to_add(date).months

      excluded_counter = 0
      while is_excluded(date)
        excluded_counter += 1

        if excluded_counter > 5
          puts "      Exclusion limit breached"
          break
        end
        date = run_exclusion(date)
      end

      # if not advanced
      #if @schedule.days == 0 && (@schedule.days_month == 'specific' || @schedule.days_month = '')
      #  puts "      simple schedule"
      #else
      #  puts "      advanced schedule"
      #end

      return date
    end

    # returns true if the schedule has expired
    def schedule_expired
      return @schedule.end_date && @date > @schedule.end_date
    end

  end
end