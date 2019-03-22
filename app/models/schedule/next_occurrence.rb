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
    def find_next_in_bitmask(bits, day, mask_length=nil)
      puts "        Searching for next in bitmask, starting on #{day}"
      return 0 if bits == 0

      mask = bitmask(bits)

      if mask_length != nil
        while mask.length < mask_length do
          mask.push('0')
        end
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
          puts "        advancing to the next week"
          weeks_since_startdate = (@date - @schedule.start_date) / 7
          weeks_to_add = (@schedule.period_num - (weeks_since_startdate % @schedule.period_num)).to_i
          date += weeks_to_add * 7
          puts "        added #{weeks_to_add} week(s) to make #{date}"
        end

        return date
      end
    end

    def find_next_month
      puts "      Searching for next monthly date"

      # if not advanced
      if @schedule.days == 0 && (@schedule.days_month == 'specific' || @schedule.days_month = '')
        puts "      simple schedule"

        days = 0b0 | (1 << @schedule.start_date.day)

        date = @date

        date += find_next_in_bitmask(days, date.day, month_length(date))

        months_since_startdate = (date.year * 12 + date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
        puts "      months (#{date}) since start date: #{months_since_startdate}"

        months_to_add = 0
        months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num) if (months_since_startdate % @schedule.period_num) > 0
        puts "      adding #{months_to_add} month(s) to #{date} to make #{date + months_to_add.months}"
        date += months_to_add.months

        return date
      end
    end

    # returns true if the schedule has expired
    def schedule_expired
      return @schedule.end_date && @date > @schedule.end_date
    end

  end
end